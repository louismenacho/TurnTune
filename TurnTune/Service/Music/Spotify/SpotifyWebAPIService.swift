//
//  SpotifyWebAPIService.swift
//  TurnTune
//
//  Created by Louis Menacho on 3/31/21.
//

import Foundation

class SpotifyWebAPIService {
    
    private var accounts = SpotifyAPIClient<SpotifyAccountsAPI>()
    private var search = SpotifyAPIClient<SpotifySearchAPI>()
    private var player = SpotifyAPIClient<SpotifyPlayerAPI>()
    private var recommendations = SpotifyAPIClient<SpotfiyRecommendationsAPI>()
        
    init() {
        loadConfiguration { [self] config in
            accounts.auth = .basic(username: config.clientID, password: config.clientSecret)
            self.generateSearchToken { error in
                print(error ?? "Search token generated")
            }
        }
    }
    
    init(config: SpotifyConfig) {
        accounts.auth = .basic(username: config.clientID, password: config.clientSecret)
    }
    
    func generateSearchToken(completion: @escaping (Error?) -> Void) {
        print("generateSearchToken")
        accounts.request(.apiToken) { [self] (result: Result<TokenResponse, Error>) in
            switch result {
            case let .failure(error):
                completion(error)
            case let .success(token):
                completion(nil)
                search.auth = .bearer(token: token.accessToken)
                recommendations.auth = .bearer(token: token.accessToken)
            }
        }
    }
    
    func setPlayerToken(_ accessToken: String) {
        player.auth = .bearer(token: accessToken)
    }
        
    func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        search.request(.search(query: query, type: "track", limit: 50)) { result in
            completion(result)
        }
    }
    
    func currentlyPlayingTrack(completion: @escaping (Result<CurrentlyPlayingResponse, Error>) -> Void) {
        player.request(.currentlyPlayingTrack) { result in
            completion(result)
        }
    }
    
    func recentlyPlayedTracks(completion: @escaping (Result<RecentlyPlayedResponse, Error>) -> Void) {
        player.request(.recentlyPlayedTracks(limit: 1)) { result in
            completion(result)
        }
    }
    
    func startPlayback(uris: [String]? = nil, position: Int = 0, completion: @escaping (Error?) -> Void) {
        player.request(.startPlayback(uris: uris, position: position)) { (result: Result<String, Error>) in
            switch result {
            case let .failure(error):
                completion(error)
            case .success:
                completion(nil)
            }
        }
    }
    
    func pausePlayback(completion: @escaping (Error?) -> Void) {
        player.request(.pausePlayback) { (result: Result<String, Error>) in
            switch result {
            case let .failure(error):
                completion(error)
            case .success:
                completion(nil)
            }
        }
    }
    
    func queueTrack(uri: String, completion: @escaping (Error?) -> Void) {
        player.request(.queueTrack(uri: uri)) { (result: Result<String, Error>) in
            switch result {
            case let .failure(error):
                completion(error)
            case .success:
                completion(nil)
            }
        }
    }
    
    func recommendations(limit: Int, seedTrackIDs: [String], completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
        recommendations.request(.recommendations(limit: limit, seedTrackIDs: seedTrackIDs)) { result in
            completion(result)
        }
    }
    
    private func loadConfiguration(completion: @escaping (SpotifyConfig) -> Void) {
        FirestoreRepository<SpotifyConfig>(collectionPath: "spotify").get(id: "configuration") { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(config):
                completion(config)
            }
        }
    }
}
