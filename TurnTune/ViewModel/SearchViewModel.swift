//
//  SearchViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/23/21.
//

import Foundation

class SearchViewModel: NSObject {
    
    var searchResult = [SearchResultItem]()
    
    private var spotifySearchAPI = SpotifyAPIClient<SpotifySearchAPI>()
    private var spotifyPlayerAPI = SpotifyAPIClient<SpotifyPlayerAPI>()
    
    init(_ session: SPTSession) {
        spotifySearchAPI.auth = .bearer(token: session.accessToken)
        spotifyPlayerAPI.auth = .bearer(token: session.accessToken)
    }
    
    func updateSpotifySession(_ session: SPTSession) {
        spotifySearchAPI.auth = .bearer(token: session.accessToken)
        spotifyPlayerAPI.auth = .bearer(token: session.accessToken)
    }
    
    func updateSearchResult(query: String, completion: @escaping (Result<Void, ClientError>) -> Void) {
        spotifySearchAPI.request(.search(query: query, type: "track", limit: 50)) { (result: Result<SearchResponse, ClientError>) in
            completion( result.flatMap { searchResult in
                self.searchResult = searchResult.tracks.items.map { SearchResultItem(from: $0) }
                return .success(())
            })
        }
    }
    
    func enqueueSong(at index: Int, completion: @escaping (Result<Song, ClientError>) -> Void) {
        self.searchResult[index].isAdded = true
        spotifyPlayerAPI.request(.queueTrack(uri: searchResult[index].song.spotifyURI)) { (result: Result<EmptyData, ClientError>) in
            switch result {
            case .failure(let error):
                self.searchResult[index].isAdded = false
                completion(.failure(error))
            case .success:
                completion(.success(self.searchResult[index].song))
            }
        }
    }
}
