//
//  HomeViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/23/21.
//

import Foundation

class HomeViewModel {
    
    func prepareSpotifyCredentials() {
        FirestoreRepository<SpotifyCredentials>(collectionPath: "spotify").get(id: "credentials") { result in
            switch result {
                case let .failure(error):
                    print(error)
                case let .success(credentials):
                    Spotify.Credentials = credentials
            }
        }
    }
}
