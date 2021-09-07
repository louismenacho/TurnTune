//
//  SpotifyWebService.swift
//  TurnTune
//
//  Created by Louis Menacho on 3/31/21.
//

import Foundation

class SpotifyWebService {
    
    private var searchAPI = SpotifyAPIClient<SpotifySearchAPI>()
    private var playerAPI = SpotifyAPIClient<SpotifyPlayerAPI>()
    private var recommendationsAPI = SpotifyAPIClient<SpotfiyRecommendationsAPI>()
    private var userProfileAPI = SpotifyAPIClient<SpotifyUserProfileAPI>()
    
    func setToken(_ accessToken: String) {
        searchAPI.auth = .bearer(token: accessToken)
        playerAPI.auth = .bearer(token: accessToken)
        recommendationsAPI.auth = .bearer(token: accessToken)
        userProfileAPI.auth = .bearer(token: accessToken)
    }
            
    func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        searchAPI.request(.search(query: query, type: "track", limit: 50)) { result in
            completion(result)
        }
    }
    
    func currentlyPlayingTrack(completion: @escaping (Result<CurrentlyPlayingResponse, Error>) -> Void) {
        playerAPI.request(.currentlyPlayingTrack) { result in
            completion(result)
        }
    }
    
    func recentlyPlayedTracks(completion: @escaping (Result<RecentlyPlayedResponse, Error>) -> Void) {
        playerAPI.request(.recentlyPlayedTracks(limit: 1)) { result in
            completion(result)
        }
    }
    
    func startPlayback(uris: [String]? = nil, position: Int = 0, completion: @escaping (Error?) -> Void) {
        playerAPI.request(.startPlayback(uris: uris, position: position)) { (result: Result<String, Error>) in
            switch result {
            case let .failure(error):
                completion(error)
            case .success:
                completion(nil)
            }
        }
    }
    
    func pausePlayback(completion: @escaping (Error?) -> Void) {
        playerAPI.request(.pausePlayback) { (result: Result<String, Error>) in
            switch result {
            case let .failure(error):
                completion(error)
            case .success:
                completion(nil)
            }
        }
    }
    
    func seek(position: Int, completion: @escaping (Error?) -> Void) {
        playerAPI.request(.seek(position: position)) { (result: Result<String, Error>) in
            switch result {
                case let .failure(error):
                    completion(error)
                case .success:
                    completion(nil)
            }
        }
    }
    
    func queueTrack(uri: String, completion: @escaping (Error?) -> Void) {
        playerAPI.request(.queueTrack(uri: uri)) { (result: Result<String, Error>) in
            switch result {
            case let .failure(error):
                completion(error)
            case .success:
                completion(nil)
            }
        }
    }
    
    func recommendations(limit: Int, seedTrackIDs: [String], completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
        recommendationsAPI.request(.recommendations(limit: limit, seedTrackIDs: seedTrackIDs)) { result in
            completion(result)
        }
    }
    
    func currentUserProfile(completion: @escaping (Result<UserProfileResponse, Error>) -> Void) {
        userProfileAPI.request(.currentUserProfile) { result in
            completion(result)
        }
    }
}
