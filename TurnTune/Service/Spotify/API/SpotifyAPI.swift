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
            if let response = handleResult(result) {
                searchToken = response.accessToken
            }
        }
    }
    
    func search(query: String, completion: @escaping (SearchResponse) -> Void) {
        APIClient<SpotifySearchAPI>().request(.search(query: query, type: "track", limit: 50), responseType: SearchResponse.self) { [self] result in
            if let response = handleResult(result) {
                completion(response)
            }
        }
    }
    
    func currentlyPlayingTrack(completion: @escaping (CurrentlyPlayingResponse) -> Void) {
        APIClient<SpotifyPlayerAPI>().request(.currentlyPlayingTrack, responseType: CurrentlyPlayingResponse.self) { [self] result in
            if let response = handleResult(result) {
                completion(response)
            }
        }
    }
    
    func playTrack(uris: [String], completion: @escaping () -> Void) {
        APIClient<SpotifyPlayerAPI>().request(.playTrack(uris: uris), responseType: String.self) { [self] result in
            _ = handleResult(result)
            completion()
        }
    }
    
    func pausePlayback(completion: @escaping () -> Void) {
        APIClient<SpotifyPlayerAPI>().request(.pausePlayback, responseType: String.self) { [self] result in
            _ = handleResult(result)
            completion()
        }
    }
    
    func queueTrack(uri: String, completion: @escaping () -> Void) {
        APIClient<SpotifyPlayerAPI>().request(.queueTrack(uri: uri), responseType: String.self) { [self] result in
            _ = handleResult(result)
            completion()
        }
    }
    
    func handleResult<T: Decodable>(_ result: Result<T, Error>) -> T? {
        switch result {
        case let .failure(error):
            print(error)
        case let .success(value):
            return value
        }
        return nil
    }
}
