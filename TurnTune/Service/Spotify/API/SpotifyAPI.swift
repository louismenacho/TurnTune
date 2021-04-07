//
//  SpotifyAPI.swift
//  TurnTune
//
//  Created by Louis Menacho on 3/31/21.
//

import Foundation

class SpotifyAPI {
    
    private(set) static var shared = SpotifyAPI()
    
    private(set) var searchToken: String = ""
    private(set) var playerToken: String = SpotifySessionManager.shared.session?.accessToken ?? ""
    
    private init() {
        generateSearchToken()
    }
    
    private func generateSearchToken() {
        APIClient<SpotifyAccountsAPI>().request(.apiToken, responseType: TokenResponse.self) { [self] result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(response):
                searchToken = response.accessToken
            }
        }
    }
    
    func setPlayerToken(_ token: String) {
        playerToken = token
    }
    
    func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        APIClient<SpotifySearchAPI>().request(.search(query: query, type: "track", limit: 50)) { result in
            completion(result)
        }
    }
    
    func currentlyPlayingTrack(completion: @escaping (Result<CurrentlyPlayingResponse, Error>) -> Void) {
        APIClient<SpotifyPlayerAPI>().request(.currentlyPlayingTrack) { result in
            completion(result)
        }
    }
    
    func playTrack(uris: [String], completion: @escaping (Error?) -> Void) {
        APIClient<SpotifyPlayerAPI>().request(.playTrack(uris: uris)) { (result: Result<String, Error>) in
            switch result {
            case let .failure(error):
                completion(error)
            case .success:
                completion(nil)
            }
        }
    }
    
    func pausePlayback(completion: @escaping (Error?) -> Void) {
        APIClient<SpotifyPlayerAPI>().request(.pausePlayback) { (result: Result<String, Error>) in
            switch result {
            case let .failure(error):
                completion(error)
            case .success:
                completion(nil)
            }
        }
    }
    
    func queueTrack(uri: String, completion: @escaping (Error?) -> Void) {
        APIClient<SpotifyPlayerAPI>().request(.queueTrack(uri: uri)) { (result: Result<String, Error>) in
            switch result {
            case let .failure(error):
                completion(error)
            case .success:
                completion(nil)
            }
        }
    }
}
