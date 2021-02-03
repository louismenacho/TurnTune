//
//  SearcherViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/28/21.
//

import Foundation

class SearcherViewModel {
    
    var searchResult = [Song]()
    
    init() {
        generateAccessToken()
    }
    
    func generateAccessToken() {
        APIService<SpotifyAccountsAPI>().request(.apiToken) { result in
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(data):
                let tokenResponse = try! JSONDecoder().decode(TokenResponse.self, from: data)
                Constants.Spotify.accessToken = tokenResponse.accessToken
            }
        }
    }
    
    func search(query: String, completion: @escaping () -> Void) {
        APIService<SpotifySearchAPI>().request(.search(query: query, type: "track", limit: 50)) { result in
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(data):
                let searchResponse = try! JSONDecoder().decode(SearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.searchResult = searchResponse.tracks.items.map { trackItem in
                        Song(
                            id: trackItem.id ,
                            name: trackItem.name,
                            artistName: trackItem.artists.map { $0.name }.joined(separator: ", "),
                            artworkURL: trackItem.album.images[0].url,
                            durationInMillis: trackItem.durationMS
                        )
                    }
                    completion()
                }
            }
        }
    }
}
