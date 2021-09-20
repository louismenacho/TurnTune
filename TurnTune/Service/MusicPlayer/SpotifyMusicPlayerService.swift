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

    private var config: SPTConfiguration
    private var appRemote: SPTAppRemote
    private var sessionManager: SPTSessionManager
    
    private var playerAPI = SpotifyAPIClient<SpotifyPlayerAPI>()
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
    
    func handleOpenURL(_ url: URL) {
        sessionManager.application(UIApplication.shared, open: url, options: [:])
    }
    
    func connect() {
        if !appRemote.isConnected && appRemote.connectionParameters.accessToken != nil {
            appRemote.connect()
        }
    }
    
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
        
    func startPlayback(songs: [Song]? = nil, position: Int = 0, completion: ((Error?) -> Void)?) {
        playerAPI.request(.startPlayback(uris: songs?.compactMap { $0.spotifyURI }, position: position)) { (result: Result<String, Error>) in
            switch result {
                case let .failure(error):
                    completion?(error)
                case .success:
                    completion?(nil)
            }
        }
    }
    
    func pausePlayback(completion: ((Error?) -> Void)?) {
        playerAPI.request(.pausePlayback) { (result: Result<String, Error>) in
            switch result {
                case let .failure(error):
                    completion?(error)
                case .success:
                    completion?(nil)
            }
        }
    }
    
    func rewindPlayback(completion: ((Error?) -> Void)?) {
        playerAPI.request(.seek(position: 0)) { (result: Result<String, Error>) in
            switch result {
                case let .failure(error):
                    completion?(error)
                case .success:
                    completion?(nil)
            }
        }
    }
    
    func isCurrentUserProfilePremium(completion: ((Bool) -> Void)?) {
        userProfileAPI.request(.currentUserProfile){ [self] (result: Result<UserProfileResponse, Error>) in
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
}

extension SpotifyMusicPlayerService: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("SPTSession didInitiate")
        playerAPI.auth = .bearer(token: session.accessToken)
        userProfileAPI.auth = .bearer(token: session.accessToken)
        appRemote.connectionParameters.accessToken = session.accessToken
        connect()
        initiateCompletion?()
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("SPTSession didRenew")
        playerAPI.auth = .bearer(token: session.accessToken)
        userProfileAPI.auth = .bearer(token: session.accessToken)
        appRemote.connectionParameters.accessToken = session.accessToken
        connect()
        initiateCompletion?()
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("SPTSession didFailWith error")
        initiateCompletion?()
    }
}

extension SpotifyMusicPlayerService: SPTAppRemoteDelegate {
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("SPTAppRemote appRemoteDidEstablishConnection")
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.setShuffle(false)
        appRemote.playerAPI?.setRepeatMode(.off)
        appRemote.playerAPI?.subscribe()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("appRemote didFailConnectionAttemptWithError")
        if let error = error {
            print(errorMessage(for: error))
        }
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("appRemote didDisconnectWithError")
        if let error = error {
            print(errorMessage(for: error))
        }
    }
    
    func errorMessage(for error: Error) -> String {
        guard
            let error = error as NSError?,
            let appRemoteErrorCode = SPTAppRemoteErrorCode(rawValue: error.code)
        else {
            return error.localizedDescription
        }
        
        switch appRemoteErrorCode {
            case .backgroundWakeupFailedError:
                return "backgroundWakeupFailedError"
            case .connectionAttemptFailedError:
                return "connectionAttemptFailedError"
            case .connectionTerminatedError:
                return "connectionTerminatedError"
            case .invalidArgumentsError:
                return "invalidArgumentsError"
            case .requestFailedError:
                return "requestFailedError"
            case .unknownError:
                return "unknownError"
            default:
                return "Could not resolve appRemoteErrorCode"
        }
    }
}

extension SpotifyMusicPlayerService: SPTAppRemotePlayerStateDelegate {
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("PLAYER STATE CHANGED")
        playerStateDidChange?(playerState)
    }
    
    func debugPlayerState(playerState: SPTAppRemotePlayerState) {
        print("\tcontextTitle: \(playerState.contextTitle)")
        print("\tcontextURI: \(playerState.contextURI)")
        print("\tisPaused: \(playerState.isPaused)")
        print("\tplaybackPosition: \(playerState.playbackPosition)")
        print("\tplaybackSpeed: \(playerState.playbackSpeed)")
        print("\turi: \(playerState.track.uri)")
        print("\ttrack name: \(playerState.track.name)")
        print("\tartist name: \(playerState.track.artist.name)")
        print("\talbum name: \(playerState.track.album.name)\n")
    }
}














//extension SpotifyMusicPlayerService: SpotifySessionManagerServiceDelegate {
//
//    func spotifySessionManagerService(didAuthorize newSession: SPTSession) {
//        webService.setToken(newSession.accessToken)
//        appRemoteService.setToken(newSession.accessToken)
//        appRemoteService.connect()
//        initiateCompletion?()
//    }
//
//    func spotifySessionManagerService(didFailWith error: SPTErrorCode) {
//        switch error {
//            case .authorizationFailed:
//                delegate?.musicPlayerServiceable(error: .authorizationFailed)
//            case .renewSessionFailed:
//                delegate?.musicPlayerServiceable(error: .renewSessionFailed)
//            case .jsonFailed:
//                delegate?.musicPlayerServiceable(error: .jsonFailed)
//            case .unknown:
//                delegate?.musicPlayerServiceable(error: .unknown)
//            default:
//                delegate?.musicPlayerServiceable(error: .unknown)
//        }
//    }
//}
//
//extension SpotifyMusicPlayerService: SpotifyAppRemoteServiceDelegate {
//
//    func spotifyAppRemoteService(didEstablishConnection appRemote: SPTAppRemote) {
//        print("spotifyAppRemoteService didEstablishConnection")
//        appRemoteService.subscribe()
//    }
//
//    func spotifyAppRemoteService(playerStateDidChange newPlayerState: SPTAppRemotePlayerState) {
////        guard let oldPlayerState = currentPlayerState else {
////            currentPlayerState = newPlayerState
////            delegate?.musicPlayerServiceable(playbackDidStart: PlayerState(from: newPlayerState))
////            return
////        }
////
////        if oldPlayerState.isPaused && !newPlayerState.isPaused {
////            delegate?.musicPlayerServiceable(playbackDidStart: PlayerState(from: newPlayerState))
////        }
////
////        if !oldPlayerState.isPaused && newPlayerState.isPaused {
////            delegate?.musicPlayerServiceable(playbackDidPause: PlayerState(from: newPlayerState))
////        }
////
////        if oldPlayerState.track.uri != newPlayerState.track.uri || oldPlayerState.contextURI != newPlayerState.contextURI {
////            delegate?.musicPlayerServiceable(playbackDidChange: PlayerState(from: newPlayerState))
////        }
////
////        if !oldPlayerState.isPaused && newPlayerState.isPaused && newPlayerState.playbackPosition == 0 {
////            delegate?.musicPlayerServiceable(playbackDidFinish: PlayerState())
////        }
////
////        currentPlayerState = newPlayerState
//        playerStateDidChange?(newPlayerState)
//    }
//}
