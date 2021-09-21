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
        accountsAPI.request(.apiToken) { [self] (result: Result<TokenResponse, HTTPError>) in
            switch result {
                case let .failure(error):
                    print(error)
                    delegate?.musicBrowserServiceable(error: .generateToken(error: error))
                case let .success(tokenResponse):
                    searchAPI.auth = .bearer(token: tokenResponse.accessToken)
                    recommendationsAPI.auth = .bearer(token: tokenResponse.accessToken)
            }
        }
    }
    
    func searchSong(query: String, completion: @escaping ([Song]) -> Void) {
        searchAPI.request(.search(query: query, type: "track", limit: 50)) { [self] (result: Result<SearchResponse, HTTPError>) in
            switch result {
                case .failure(let error):
                    delegate?.musicBrowserServiceable(error: .searchSong(error: error))
                case .success(let response):
                    let songSearchResult = response.tracks.items.map { Song(from: $0) }
                    completion(songSearchResult)
            }
        }
    }
    
    func getSongRecommendations(from recentSongs: [Song], completion: @escaping ([Song]) -> Void) {
        recommendationsAPI.request(.recommendations(limit: 20, seedTrackIDs: recentSongs.compactMap { $0.spotifyID })) { [self] (result: Result<RecommendationsResponse, HTTPError>) in
            switch result {
                case .failure(let error):
                    delegate?.musicBrowserServiceable(error: .getSongRecommendations(error: error))
                case .success(let response):
                    let recommendationsResult = response.tracks.map { Song(from: $0) }
                    completion(recommendationsResult)
            }
        }
    }
}
