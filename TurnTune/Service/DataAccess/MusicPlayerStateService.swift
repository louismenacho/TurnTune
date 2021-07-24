//
//  MusicPlayerStateService.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/21/21.
//

import Foundation

class MusicPlayerStateService {
    
    private var playerStateRepository: FirestoreRepository<PlayerState> {
        FirestoreRepository<PlayerState>(collectionPath: "rooms/"+currentRoomID+"/player")
    }

    private var currentRoomID: String {
        UserDefaultsRepository().roomID
    }
    
    func getPlayerState(completion: @escaping (Result<PlayerState, Error>) -> Void) {
        playerStateRepository.get(id: "state") { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(playerState):
                completion(.success(playerState))
            }
        }
    }
        
    func updatePlayerState(_ playerState: PlayerState, completion: @escaping (Error?) -> Void) {
        playerStateRepository.update(playerState) { error in
            completion(error)
        }
    }
    
    func playerStateChangeListener(completion: @escaping (Result<PlayerState, Error>) -> Void) {
        playerStateRepository.addListener(id: "state") { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(playerState):
                completion(.success(playerState))
            }
        }
    }
}
