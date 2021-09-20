//
//  SpotifyCredentialsDataAccessProvider.swift
//  TurnTune
//
//  Created by Louis Menacho on 9/5/21.
//

import Foundation

class SpotifyCredentialsDataAccessProvider: DataAccessProvider {
    
    weak var delegate: DataAccessProviderDelegate?
        
    private var spotifyCredentialsRepository = {
        FirestoreRepository<SpotifyCredentials>(collectionPath: "spotify")
    }()

    func getSpotifyCredentials(completion: @escaping (SpotifyCredentials) -> Void) {
        spotifyCredentialsRepository.get(id: "credentials") { [self] result in
            switch result {
                case let .failure(error):
                    delegate?.dataAccessProvider(self, error: .spotifyConfig(error: error))
                case let .success(config):
                    completion(config)
            }
        }
    }
}
