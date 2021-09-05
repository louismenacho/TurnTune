//
//  SpotifyConfigDataAccessProvider.swift
//  TurnTune
//
//  Created by Louis Menacho on 9/5/21.
//

import Foundation

class SpotifyConfigDataAccessProvider: DataAccessProvider {
    
    weak var delegate: DataAccessProviderDelegate?
        
    private var spotifyConfigRepository = {
        FirestoreRepository<SpotifyConfig>(collectionPath: "spotify")
    }()

    func getSpotifyConfig(completion: @escaping (SpotifyConfig) -> Void) {
        spotifyConfigRepository.get(id: "configuration") { [self] result in
            switch result {
                case let .failure(error):
                    delegate?.dataAccessProvider(self, error: .spotifyConfig(error: error))
                case let .success(config):
                    completion(config)
            }
        }
    }
}
