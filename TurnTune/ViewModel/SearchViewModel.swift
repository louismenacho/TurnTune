//
//  SearchViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/23/21.
//

import Foundation

class SearchViewModel {
    
    var searchAPI = SpotifyAPIClient<SpotifySearchAPI>()
    
    init(_ session: SPTSession) {
        searchAPI.auth = .bearer(token: session.accessToken)
    }
    
    func search(query: String, completion: @escaping (Result<SearchResponse, ClientError>) -> Void) {
        searchAPI.request(.search(query: query, type: "track", limit: 50)) { (result: Result<SearchResponse?, ClientError>) in
            if let response = try? result.get() {
                completion(.success(response))
                return
            }
            if case let .failure(error) = result {
                completion(.failure(error))
                return
            }
        }
    }
}
