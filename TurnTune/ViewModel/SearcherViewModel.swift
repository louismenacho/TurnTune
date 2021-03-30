//
//  SearcherViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/28/21.
//

import Foundation

class SearcherViewModel {
    
    var searchResult = [Song]()
    var spotifyAccountsAPI = APIClient<SpotifyAccountsAPI>()
    var spotifySearchAPI = APIClient<SpotifySearchAPI>()
    
    init() {
        generateAccessToken()
    }
    
    func generateAccessToken(completion: ( (TokenResponse) -> Void )? = nil) {
        APIClient<SpotifyAccountsAPI>().request(.apiToken, responseType: TokenResponse.self) { result in
            // Move to SpotifyAPI and create delegate to handle errors
        }
//        spotifyAccountsAPI.request(.apiToken) { result in
//            Spotify.APIToken.searchToken = try! result.get().accessToken
//            completion?
//        }
//        APIClient<SpotifyAccountsAPI>().request(.apiToken) { result in
//            self.token = try! result.get()
//            switch result {
//            case let .failure(error):
//                print(error.localizedDescription)
//            case let .success(tokenResponse):
//                self.accessToken = tokenResponse.accessToken
//            }
//        }
    }
    
    func search(query: String, completion: @escaping (SearchResponse) -> Void) {
        APIClient<SpotifySearchAPI>().request(.search(query: query, type: "track", limit: 50)) { result in
            completion(try! result.get())
//            switch result {
//            case let .failure(error):
//                print(error.localizedDescription)
//            case let .success(data):
//                do {
//                    let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
//                    DispatchQueue.main.async {
//                        self.searchResult = searchResponse.tracks.items.compactMap { trackItem in
//                            trackItem == nil ? nil : Song(spotifyTrack: trackItem!)
//                        }
//                        completion()
//                    }
//                } catch  {
//                    print(error)
//                    print(String(data: data, encoding: .utf8) ?? "")
//                }
//            }
        }
    }
}
