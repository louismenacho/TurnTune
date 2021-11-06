//
//  SpotifyMusicPlayerService.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/14/21.
//

import Foundation

class SpotifyMusicPlayerService: NSObject, MusicPlayerServiceable {
    
    weak var delegate: MusicPlayerServiceableDelegate?
    
    private var initiateCompletion: (() -> Void)?
    private var playerStateDidChange: ((SPTAppRemotePlayerState) -> Void)?
    private var connectionStatusDidChange: ((Bool) -> Void)?

    private var config: SPTConfiguration
    private(set) var appRemote: SPTAppRemote
    private var sessionManager: SPTSessionManager
    
    private(set) var playerAPI = SpotifyAPIClient<SpotifyPlayerAPI>()
    private var userProfileAPI = SpotifyAPIClient<SpotifyUserProfileAPI>()
    
    private var scope: SPTScope = [
        .appRemoteControl,
        .userReadCurrentlyPlaying,
        .userReadRecentlyPlayed,
        .userReadPlaybackState,
        .userModifyPlaybackState,
        .userReadPrivate
    ]
    
    init(credentials: SpotifyCredentials) {
        config = SPTConfiguration(clientID: credentials.clientID, redirectURL: URL(string: credentials.redirectURL)!)
        config.tokenSwapURL = URL(string: credentials.tokenSwapURL)
        config.tokenRefreshURL = URL(string: credentials.tokenRefreshURL)
        appRemote = SPTAppRemote(configuration: config, logLevel: .debug)
        sessionManager = SPTSessionManager(configuration: config, delegate: nil)
    }
    
    func initiateSession(playing song: Song? = nil, completion: (() -> Void)?) {
        config.playURI = song?.spotifyURI
        appRemote.delegate = self
        sessionManager.delegate = self
        sessionManager.initiateSession(with: scope, options: .clientOnly)
        initiateCompletion = {
            completion?()
        }
    }
    
    func renewSession() {
        sessionManager.renewSession()
    }
    
    func handleOpenURL(_ url: URL?) {
        guard let url = url else {
            delegate?.musicPlayerServiceable(error: .initiate(error: nil))
            return
        }
        DispatchQueue.main.async { [self] in
            sessionManager.application(UIApplication.shared, open: url, options: [:])
        }
    }
    
    func connect() {
        if !appRemote.isConnected && appRemote.connectionParameters.accessToken != nil {
            print("attempting connect")
            appRemote.connect()
        }
    }
    
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
        
    func startPlayback(songs: [Song]? = nil, position: Int = 0, completion: (() -> Void)?) {
        playerAPI.request(.startPlayback(uris: songs?.compactMap { $0.spotifyURI }, position: position)) { (result: Result<String, HTTPError>) in
        } emptyCompletion: { [self] (result: Result<Void, HTTPError>) in
            switch result {
                case let .failure(error):
                    delegate?.musicPlayerServiceable(error: .startPlayback(error: error))
                case .success:
                    completion?()
            }
        }
    }
    
    func pausePlayback(completion: (() -> Void)?) {
        playerAPI.request(.pausePlayback) { (result: Result<String, HTTPError>) in
        } emptyCompletion: { [self] (result: Result<Void, HTTPError>) in
            switch result {
                case let .failure(error):
                    delegate?.musicPlayerServiceable(error: .pausePlayback(error: error))
                case .success:
                    completion?()
            }
        }
    }
    
    func rewindPlayback(completion: (() -> Void)?) {
        playerAPI.request(.seek(position: 1000)) { (result: Result<String, HTTPError>) in
        } emptyCompletion: { [self] (result: Result<Void, HTTPError>) in
            switch result {
                case let .failure(error):
                    delegate?.musicPlayerServiceable(error: .rewindPlayback(error: error))
                case .success:
                    completion?()
            }
        }
    }
    
    func isCurrentUserProfilePremium(completion: ((Bool) -> Void)?) {
        userProfileAPI.request(.currentUserProfile) { [self] (result: Result<UserProfileResponse, HTTPError>) in
            switch result {
                case let .failure(error):
                    delegate?.musicPlayerServiceable(error: .currentUserProfile(error: error))
                case let .success(userProfile):
                    completion?(userProfile.product == "premium")
            }
        }
    }
    
    func playerStateChangeListener(completion: @escaping (PlayerState) -> Void) {
        playerStateDidChange = { playerState in
            completion(PlayerState(from: playerState))
        }
    }
    
    func connectionStatusChangeListener(completion: @escaping (Bool) -> Void) {
        connectionStatusDidChange = { isConnected in
            completion(isConnected)
        }
    }

    
    func getPlayerState(completion: @escaping (PlayerStateResponse?) -> Void) {
        playerAPI.request(.playerState) { [self] (result: Result<PlayerStateResponse?, HTTPError>) in
            switch result {
                case let .failure(error):
                    delegate?.musicPlayerServiceable(error: .getPlayerState(error: error))
                case let .success(playerStateResponse):
                    completion(playerStateResponse)
            }
        } emptyCompletion: { [self] (result: Result<Void, HTTPError>) in
            switch result {
                case let .failure(error):
                    delegate?.musicPlayerServiceable(error: .getPlayerState(error: error))
                case .success:
                    completion(nil)
            }
        }
    }
}

extension SpotifyMusicPlayerService: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("SPTSession didInitiate")
        playerAPI.auth = .bearer(token: session.accessToken)
        userProfileAPI.auth = .bearer(token: session.accessToken)
        appRemote.connectionParameters.accessToken = session.accessToken
        initiateCompletion?()
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("SPTSession didRenew")
        playerAPI.auth = .bearer(token: session.accessToken)
        userProfileAPI.auth = .bearer(token: session.accessToken)
        appRemote.connectionParameters.accessToken = session.accessToken
        initiateCompletion?()
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("SPTSession didFailWith error")
        if let error = error as NSError? {
            DispatchQueue.main.async { [self] in
                if !sessionManager.isSpotifyAppInstalled {
                    delegate?.musicPlayerServiceable(error: .spotifyAppNotInstalled)
                } else {
                    delegate?.musicPlayerServiceable(error: .spotify(code: SPTErrorCode(rawValue: UInt(error.code)) ?? .unknown))
                }
            }
        }
    }
}

extension SpotifyMusicPlayerService: SPTAppRemoteDelegate {
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("SPTAppRemote appRemoteDidEstablishConnection")
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.setShuffle(false)
        appRemote.playerAPI?.setRepeatMode(.off)
        appRemote.playerAPI?.subscribe()
        connectionStatusDidChange?(true)
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("appRemote didFailConnectionAttemptWithError")
        if let error = error as NSError? {
            delegate?.musicPlayerServiceable(error: .spotifyAppRemote(code: SPTAppRemoteErrorCode(rawValue: error.code) ?? .unknownError))
        }
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("appRemote didDisconnectWithError")
        if let error = error as NSError? {
            delegate?.musicPlayerServiceable(error: .spotifyAppRemote(code: SPTAppRemoteErrorCode(rawValue: error.code) ?? .unknownError))
        }
        connectionStatusDidChange?(false)
    }
}

extension SpotifyMusicPlayerService: SPTAppRemotePlayerStateDelegate {
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        if playerState.isPaused {
            print("playstate is paused")
            print("track.name \(playerState.track.name)")
            print("isPaused \(playerState.isPaused)")
            print("playbackPosition \(playerState.playbackPosition)")
            print("contextURI \(playerState.contextURI)")
            print("contextTitle \(playerState.contextTitle)")
            print("")
        }
        if !playerState.contextURI.absoluteString.isEmpty {
            print("playerstate hass no context")
            print("track.name \(playerState.track.name)")
            print("isPaused \(playerState.isPaused)")
            print("playbackPosition \(playerState.playbackPosition)")
            print("contextURI \(playerState.contextURI)")
            print("contextTitle \(playerState.contextTitle)")
            print("")
        }
        playerStateDidChange?(playerState)
    }
}
