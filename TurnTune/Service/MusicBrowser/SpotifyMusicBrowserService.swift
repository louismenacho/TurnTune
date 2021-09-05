//
//  SpotifyMusicBrowserService.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/18/21.
//

import Foundation

class SpotifyMusicBrowserService: MusicBrowserServiceable {
    
    weak var delegate: MusicBrowserServiceableDelegate?
    
    private var webService = SpotifyWebService()
    private var accountsService = SpotifyAccountsService()
    private var spotifyConfigDataAccess = SpotifyConfigDataAccessProvider()
    
    func initiate(completion: (() -> Void)?) {
        spotifyConfigDataAccess.getSpotifyConfig { [self] config in
            accountsService.setClientCredentials(clientID: config.clientID, clientSecret: config.clientID)
            generateToken {
                completion?()
            }
        }
    }
    
    func generateToken(completion: (() -> Void)?) {
        accountsService.generateToken {[self] (result: Result<TokenResponse, Error>) in
            switch result {
                case let .failure(error):
                    delegate?.musicBrowserServiceable(error: .initiate(error: error))
                case let .success(tokenResponse):
                    webService.setToken(tokenResponse.accessToken)
            }
        }
    }
    
    func searchSong(query: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        webService.search(query: query) { (result: Result<SearchResponse, Error>) in
            let songSearchResult = Result {
                try result.get().tracks.items.map { trackItem in
                    Song(from: trackItem)
                }
            }
            completion(songSearchResult)
        }
    }
    
    func getRecentlyPlayedTracks(completion: @escaping (Result<[Song], Error>) -> Void) {
        webService.recentlyPlayedTracks { (result: Result<RecentlyPlayedResponse, Error>) in
            let recentlyPlayedTracksResult = Result {
                try result.get().items.map { item in
                    Song(from: item)
                }
            }
            completion(recentlyPlayedTracksResult)
        }
    }
    
    func getSongRecommendations(from recentSongs: [Song], completion: @escaping (Result<[Song], Error>) -> Void) {
        webService.recommendations(limit: 20, seedTrackIDs: recentSongs.compactMap { $0.spotifyID }) { (result: Result<RecommendationsResponse, Error>) in
            let recommendationsResult = Result {
                try result.get().tracks.map { track in
                    Song(from: track)
                }
            }
            completion(recommendationsResult)
        }
    }
    
}
