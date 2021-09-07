//
//  SpotifyMusicPlayerService.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/14/21.
//

import Foundation

class SpotifyMusicPlayerService: MusicPlayerServiceable {
    
    weak var delegate: MusicPlayerServiceableDelegate?
    
    private(set) var sessionManagerService = SpotifySessionManagerService()
    private(set) var appRemoteService = SpotifyAppRemoteService()
    private(set) var webService = SpotifyWebService()
    
    private var currentPlayerState: SPTAppRemotePlayerState?
    private var initiateCompletion: (() -> Void)?
    private var playerStateDidChange: ((SPTAppRemotePlayerState) -> Void)?
        
    init() {
        sessionManagerService.delegate = self
        appRemoteService.delegate = self
    }
    
    func initiate(with song: Song? = nil, completion: (() -> Void)?) {
        sessionManagerService.initiate(with: song?.spotifyURI)
        initiateCompletion = {
            completion?()
        }
    }
    
    func checkCurrentUserProfileIsPremium(completion: @escaping () -> Void) {
        currentUserProfileIsPremium { [self] isPremium in
            if isPremium {
                completion()
            } else {
                delegate?.musicPlayerServiceable(error: .cannotPlayOnDemand)
            }
        }
    }
    
    func startPlayback(songs: [Song]? = nil, position: Int = 0, completion: (() -> Void)?) {
        webService.startPlayback(uris: songs?.compactMap { $0.spotifyURI }, position: position) { [self] error in
            if let error = error {
                delegate?.musicPlayerServiceable(error: .startPlayback(error: error))
            } else {
                completion?()
            }
        }
    }
    
    func pausePlayback(completion: (() -> Void)?) {
        webService.pausePlayback { [self] error in
            if let error = error {
                delegate?.musicPlayerServiceable(error: .pausePlayback(error: error))
            } else {
                completion?()
            }
        }
    }
    
    func rewindPlayback(completion: (() -> Void)?) {
        webService.seek(position: 0) { [self] error in
            if let error = error {
                delegate?.musicPlayerServiceable(error: .rewindPlayback(error: error))
            } else {
                completion?()
            }
        }
    }
    
    func currentUserProfileIsPremium(completion: ((Bool) -> Void)?) {
        webService.currentUserProfile { [self] result in
            switch result {
                case let .failure(error):
                    delegate?.musicPlayerServiceable(error: .currentUserProfile(error: error))
                case let .success(userProfile):
                    completion?(userProfile.product == "premium")
            }
        }
    }
    
    func playerStateChangeListener(completion: @escaping (PlayerState) -> Void) {
        appRemoteService.subscribe()
        playerStateDidChange = { playerState in
            completion(PlayerState(from: playerState))
        }
    }
}

extension SpotifyMusicPlayerService: SpotifySessionManagerServiceDelegate {
    
    func spotifySessionManagerService(didAuthorize newSession: SPTSession) {
        webService.setToken(newSession.accessToken)
        appRemoteService.setToken(newSession.accessToken)
        appRemoteService.connect()
        initiateCompletion?()
    }
}

extension SpotifyMusicPlayerService: SpotifyAppRemoteServiceDelegate {
    
    func spotifyAppRemoteService(didEstablishConnection appRemote: SPTAppRemote) {
        print("spotifyAppRemoteService didEstablishConnection")
        appRemoteService.subscribe()
    }
        
    func spotifyAppRemoteService(playerStateDidChange newPlayerState: SPTAppRemotePlayerState) {
//        guard let oldPlayerState = currentPlayerState else {
//            currentPlayerState = newPlayerState
//            delegate?.musicPlayerServiceable(playbackDidStart: PlayerState(from: newPlayerState))
//            return
//        }
//
//        if oldPlayerState.isPaused && !newPlayerState.isPaused {
//            delegate?.musicPlayerServiceable(playbackDidStart: PlayerState(from: newPlayerState))
//        }
//
//        if !oldPlayerState.isPaused && newPlayerState.isPaused {
//            delegate?.musicPlayerServiceable(playbackDidPause: PlayerState(from: newPlayerState))
//        }
//
//        if oldPlayerState.track.uri != newPlayerState.track.uri || oldPlayerState.contextURI != newPlayerState.contextURI {
//            delegate?.musicPlayerServiceable(playbackDidChange: PlayerState(from: newPlayerState))
//        }
//
//        if !oldPlayerState.isPaused && newPlayerState.isPaused && newPlayerState.playbackPosition == 0 {
//            delegate?.musicPlayerServiceable(playbackDidFinish: PlayerState())
//        }
//
//        currentPlayerState = newPlayerState
        playerStateDidChange?(newPlayerState)
    }
}
