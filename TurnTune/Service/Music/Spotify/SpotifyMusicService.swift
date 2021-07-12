//
//  SpotifyMusicService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/19/21.
//

import Foundation


class SpotifyMusicService: MusicServiceable {
    
    weak var delegate: MusicServiceableDelegate?
    
    private(set) var sessionManager = SpotifySessionManagerService()
    private(set) var appRemote = SpotifyAppRemoteService()
    private var webAPI = SpotifyWebAPIService()
    private var lastPlayerState: SPTAppRemotePlayerState?
    
    init() {
        appRemote.delegate = self
        sessionManager.delegate = self
        sessionManager.initiateSession()
    }
        
    func startPlayback(songs: [Song]? = nil, position: Int = 0, completion: @escaping (Error?) -> Void) {
        webAPI.startPlayback(uris: songs?.compactMap { $0.spotifyURI }, position: position) { error in
            completion(error)
        }
    }
    
    func pausePlayback(completion: @escaping (Error?) -> Void) {
        webAPI.pausePlayback { error in
            completion(error)
        }
    }
        
    func searchSong(query: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        webAPI.search(query: query) { (result: Result<SearchResponse, Error>) in
            let songSearchResult = Result {
                try result.get().tracks.items.map { trackItem in
                    Song(spotifyTrack: trackItem)
                }
            }
            completion(songSearchResult)
        }
    }
    
    func recentlyPlayedTracks(completion: @escaping (Result<[Song], Error>) -> Void) {
        webAPI.recentlyPlayedTracks { (result: Result<RecentlyPlayedResponse, Error>) in
            let recentlyPlayedTracksResult = Result {
                try result.get().items.map { item in
                    Song(spotifyTrack: item.track)
                }
            }
            completion(recentlyPlayedTracksResult)
        }
    }
    
    func play(song: Song, asRadio flag: Bool = false, completion: @escaping (Error?) -> Void) {
        appRemote.play(trackUri: song.spotifyURI ?? "No URI", asRadio: flag ) { error in
            completion(error)
        }
    }
    
    func getSongRecommendations(from recentSongs: [Song], completion: @escaping (Result<[Song], Error>) -> Void) {
        webAPI.recommendations(limit: 20, seedTrackIDs: recentSongs.compactMap { $0.id }) { (result: Result<RecommendationsResponse, Error>) in
            let recommendationsResult = Result {
                try result.get().tracks.map { track in
                    Song(spotifyTrack: track)
                }
            }
            completion(recommendationsResult)
        }
    }
}

extension SpotifyMusicService: SpotifyAppRemoteServiceDelegate {
    
    func spotifyAppRemoteService(didEstablishConnection appRemote: SPTAppRemote) {
        
    }
        
    func spotifyAppRemoteService(playerStateDidChange playerState: SPTAppRemotePlayerState) {
        if lastPlayerState == nil {
            delegate?.musicServiceable(musicServiceable: self, didInitiateWith: PlayerState(spotifyPlayerState: playerState))
        }
        
        if lastPlayerState?.track.uri != playerState.track.uri {
            delegate?.musicServiceable(musicServiceable: self, playingSongDidChange: PlayerState(spotifyPlayerState: playerState))
        }
        
        if playerState.isPaused && lastPlayerState?.isPaused == false, playerState.playbackPosition == 0 {
            delegate?.musicServiceable(musicServiceable: self, playingSongDidFinish: PlayerState(spotifyPlayerState: playerState))
        }
        
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
        appRemote.setToken(session.accessToken)
        webAPI.setPlayerToken(session.accessToken)
    }
}
