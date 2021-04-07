//
//  SearcherViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/28/21.
//

import Foundation

class SearcherViewModel {
    
    private(set) var searchResult = [Song]()
    private(set) var spotifyAPI = SpotifyAPI.shared
    
    func search(query: String, completion: @escaping () -> Void) {
        spotifyAPI.search(query: query) { [self] result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(searchResponse):
                searchResult = searchResponse.tracks.items.compactMap { trackItem in
                    trackItem == nil ? nil : Song(spotifyTrack: trackItem!)
                }
                completion()
            }
        }
    }
}
