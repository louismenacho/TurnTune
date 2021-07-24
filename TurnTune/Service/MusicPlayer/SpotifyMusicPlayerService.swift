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
    
//    func playNextSong(completion: @escaping (Error?) -> Void) {
//        if let nextSong = queue.first {
//            startPlayback(songs: [nextSong]) { error in
//                completion(error)
//            }
//            return
//        }
//
//        if !history.isEmpty {
//            let recentSongs = Array(history.prefix(5))
//            musicBrowser.getSongRecommendations(from: recentSongs) { [self] recommendedSongs in
//                startPlayback(songs: recentSongs) { error in
//                    completion(error)
//                }
//            }
//            return
//        }
//    }
}

extension SpotifyMusicPlayerService: SpotifyAppRemoteServiceDelegate {
    
    func spotifyAppRemoteService(didAuthorize newSession: SPTSession) {
        print("spotifyAppRemoteService didAuthorize")
        webService.setPlayerToken(newSession.accessToken)
    }
    
    func spotifyAppRemoteService(didEstablishConnection appRemote: SPTAppRemote) {
        print("spotifyAppRemoteService didEstablishConnection")
        appRemoteService.subscribe()
    }
        
    func spotifyAppRemoteService(playerStateDidChange playerState: SPTAppRemotePlayerState) {
        print("spotifyAppRemoteService playerStateDidChange")
        
        guard let currentPlayerState = self.currentPlayerState else {
            delegate?.musicPlayerServiceable(playbackDidStart: PlayerState(from: playerState))
            return
        }

        if currentPlayerState.track.uri != playerState.track.uri {
            delegate?.musicPlayerServiceable(playbackDidChange: PlayerState(from: playerState))
        }

        if !currentPlayerState.isPaused && playerState.isPaused && playerState.playbackPosition == 0 {
            delegate?.musicPlayerServiceable(playbackDidFinish: PlayerState(from: playerState))
        }
        
        self.currentPlayerState = playerState
    }
}
