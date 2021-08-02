//
//  SpotifyMusicPlayerService.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/14/21.
//

import Foundation

class SpotifyMusicPlayerService: MusicPlayerServiceable {
    
    var delegate: MusicPlayerServiceableDelegate?
    
    private(set) var appRemoteService = SpotifyAppRemoteService()
    private(set) var webService = SpotifyWebService()
    
    private var currentPlayerState: SPTAppRemotePlayerState?
        
    init() {
        appRemoteService.delegate = self
        appRemoteService.initiate(play: "")
    }
    
    func initiate(delegate: MusicPlayerServiceableDelegate?) {
        self.delegate = delegate
        appRemoteService.initiate()
    }
    
    func startPlayback(songs: [Song]? = nil, position: Int = 0, completion: @escaping (Error?) -> Void) {
        webService.startPlayback(uris: songs?.compactMap { $0.spotifyURI }, position: position) { error in
            completion(error)
        }
    }
    
    func pausePlayback(completion: @escaping (Error?) -> Void) {
        webService.pausePlayback { error in
            completion(error)
        }
    }
}

extension SpotifyMusicPlayerService: SpotifyAppRemoteServiceDelegate {
    
    func spotifyAppRemoteService(didAuthorize newSession: SPTSession) {
//        print("spotifyAppRemoteService didAuthorize")
        webService.setPlayerToken(newSession.accessToken)
    }
    
    func spotifyAppRemoteService(didEstablishConnection appRemote: SPTAppRemote) {
        print("spotifyAppRemoteService didEstablishConnection")
        appRemoteService.subscribe()
    }
        
    func spotifyAppRemoteService(playerStateDidChange newPlayerState: SPTAppRemotePlayerState) {
        guard let oldPlayerState = currentPlayerState else {
            currentPlayerState = newPlayerState
            delegate?.musicPlayerServiceable(playbackDidStart: PlayerState(from: newPlayerState))
            return
        }
        
        if oldPlayerState.isPaused && !newPlayerState.isPaused {
            delegate?.musicPlayerServiceable(playbackDidStart: PlayerState(from: newPlayerState))
        }
        
        if !oldPlayerState.isPaused && newPlayerState.isPaused {
            delegate?.musicPlayerServiceable(playbackDidPause: PlayerState(from: newPlayerState))
        }

        if oldPlayerState.track.uri != newPlayerState.track.uri || oldPlayerState.contextURI != newPlayerState.contextURI {
            delegate?.musicPlayerServiceable(playbackDidChange: PlayerState(from: newPlayerState))
        }

        if !oldPlayerState.isPaused && newPlayerState.isPaused && newPlayerState.playbackPosition == 0 {
            delegate?.musicPlayerServiceable(playbackDidFinish: PlayerState())
        }
        
        currentPlayerState = newPlayerState
    }
}
