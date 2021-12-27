//
//  SearchViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/23/21.
//

import Foundation

class SearchViewModel {
    
    var searchResult = [SearchResultItem]()
    
    private var searchAPI = SpotifyAPIClient<SpotifySearchAPI>()
    
    init(_ session: SPTSession) {
        searchAPI.auth = .bearer(token: session.accessToken)
    }
    
    func updateSearchResult(query: String, completion: @escaping (Result<Void, ClientError>) -> Void) {
        searchAPI.request(.search(query: query, type: "track", limit: 50)) { (result: Result<SearchResponse, ClientError>) in
            completion( result.flatMap { searchResult in
                self.searchResult = searchResult.tracks.items.map { SearchResultItem(from: $0) }
                return .success(())
            })
        }
    }
}
