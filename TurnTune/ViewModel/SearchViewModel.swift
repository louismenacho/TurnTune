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
    private var playerAPI = SpotifyAPIClient<SpotifyPlayerAPI>()
    
    init(_ session: SPTSession) {
        searchAPI.auth = .bearer(token: session.accessToken)
        playerAPI.auth = .bearer(token: session.accessToken)
    }
    
    func updateSearchResult(query: String, completion: @escaping (Result<Void, ClientError>) -> Void) {
        searchAPI.request(.search(query: query, type: "track", limit: 50)) { (result: Result<SearchResponse, ClientError>) in
            completion( result.flatMap { searchResult in
                self.searchResult = searchResult.tracks.items.map { SearchResultItem(from: $0) }
                return .success(())
            })
        }
    }
    
    func enqueueSong(at index: Int, completion: @escaping (Result<Void, ClientError>) -> Void) {
        self.searchResult[index].isAdded = true
        playerAPI.request(.queueTrack(uri: searchResult[index].song.spotifyURI)) { (result: Result<EmptyData, ClientError>) in
            switch result {
            case .failure(let error):
                self.searchResult[index].isAdded = false
                completion(.failure(error))
            case .success:
                completion(.success(()))
            }
        }
    }
}
