//
//  SpotifyMusicBrowserService.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/18/21.
//

import Foundation

class SpotifyMusicBrowserService: MusicBrowserServiceable {
    
    weak var delegate: MusicBrowserServiceableDelegate?
    
    private var accountsAPI = SpotifyAPIClient<SpotifyAccountsAPI>()
    private var searchAPI = SpotifyAPIClient<SpotifySearchAPI>()
    private var recommendationsAPI = SpotifyAPIClient<SpotfiyRecommendationsAPI>()
    private var spotifyConfigDataAccess = SpotifyCredentialsDataAccessProvider()
    
    func initiate(completion: (() -> Void)?) {
        spotifyConfigDataAccess.getSpotifyCredentials { [self] config in
            accountsAPI.auth = .basic(username: config.clientID, password: config.clientSecret)
            generateToken {
                completion?()
            }
        }
    }
    
    func generateToken(completion: (() -> Void)?) {
        accountsAPI.request(.apiToken) { [self] (result: Result<TokenResponse, Error>) in
            switch result {
                case let .failure(error):
                    print(error)
                    delegate?.musicBrowserServiceable(error: .initiate(error: error))
                case let .success(tokenResponse):
                    searchAPI.auth = .bearer(token: tokenResponse.accessToken)
                    recommendationsAPI.auth = .bearer(token: tokenResponse.accessToken)
            }
        }
    }
    
    func searchSong(query: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        searchAPI.request(.search(query: query, type: "track", limit: 50)) { (result: Result<SearchResponse, Error>) in
            let songSearchResult = Result {
                try result.get().tracks.items.map { trackItem in
                    Song(from: trackItem)
                }
            }
            completion(songSearchResult)
        }
    }
    
    func getSongRecommendations(from recentSongs: [Song], completion: @escaping (Result<[Song], Error>) -> Void) {
        recommendationsAPI.request(.recommendations(limit: 20, seedTrackIDs: recentSongs.compactMap { $0.spotifyID })) { (result: Result<RecommendationsResponse, Error>) in
            let recommendationsResult = Result {
                try result.get().tracks.map { track in
                    Song(from: track)
                }
            }
            completion(recommendationsResult)
        }
    }
}
