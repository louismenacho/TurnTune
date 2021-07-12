//
//  SpotifyMusicService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/19/21.
//

import Foundation

class SpotifyMusicService: MusicServiceable {
    
    var playingSongDidEnd: (() -> Void)?
    
    private(set) var sessionManager = SpotifySessionManagerService()
    private(set) var appRemote = SpotifyAppRemoteService()
    private var webAPI = SpotifyWebAPIService()
    private var lastPlayerState: SPTAppRemotePlayerState?
    
    init() {
        appRemote.delegate = self
        sessionManager.delegate = self
        sessionManager.initiateSession()
    }
    
    func play(song: Song? = nil, completion: @escaping (Error?) -> Void) {
        webAPI.playTrack(uris: []) { error in
            completion(error)
        }
    }
    
    func pause(completion: @escaping (Error?) -> Void) {
        webAPI.pausePlayback { error in
            completion(error)
        }
    }
        
    func searchSong(query: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        webAPI.search(query: query) { (result: Result<SearchResponse, Error>) in
            let songSearchResult = Result {
                try result.get().tracks.items.compactMap { trackItem in
                    trackItem == nil ? nil : Song(spotifyTrack: trackItem!)
                }
            }
            completion(songSearchResult)
        }
    }
    
    func recentlyPlayedTracks() {
        webAPI.recentlyPlayedTracks { (result: Result<RecentlyPlayedResponse, Error>) in
            switch result {
            case .failure:
                print("recetlyPlayed error")
            case .success(let response):
                print(response.items?.forEach({ item in
                    print(item.track?.name)
                }))
            }
        }
    }
}

extension SpotifyMusicService: SpotifyAppRemoteServiceDelegate {
    
    func spotifyAppRemoteService(didEstablishConnection appRemote: SPTAppRemote) {
        
    }
        
    func spotifyAppRemoteService(playerStateDidChange playerState: SPTAppRemotePlayerState) {
        
        lastPlayerState = playerState
    }
}

extension SpotifyMusicService: SpotifySessionManagerServiceDelegate {
    
    func spotifySessionManagerService(didInitiate session: SPTSession) {
        appRemote.setToken(session.accessToken)
        appRemote.connect()
        
        webAPI.setPlayerToken(session.accessToken)
    }
    
    func spotifySessionManagerService(didRenew session: SPTSession) {
        
    }
}
