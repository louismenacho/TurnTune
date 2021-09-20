//
//  PlayerStateDataAccessProvider.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/21/21.
//

import Foundation

class PlayerStateDataAccessProvider: DataAccessProvider {
    
    weak var delegate: DataAccessProviderDelegate?
    
    private var currentRoomID: String {
        UserDefaultsRepository().roomID
    }
    
    private var playerStateRepository: FirestoreRepository<PlayerState> {
        FirestoreRepository<PlayerState>(collectionPath: "rooms/"+currentRoomID+"/player")
    }
    
    func createPlayerState(playerState: PlayerState ,completion: (() -> Void)? = nil) {
        playerStateRepository.create(playerState) { [self] error in
            if let error = error {
                delegate?.dataAccessProvider(self, error: .playerState(error: error))
            } else {
                completion?()
            }
        }
    }
            
    func updatePlayerState(_ playerState: PlayerState, completion: (() -> Void)? = nil) {
        playerStateRepository.update(playerState) { [self] error in
            if let error = error {
                delegate?.dataAccessProvider(self, error: .playerState(error: error))
            } else {
                completion?()
            }
        }
    }
    
    func playerStateChangeListener(completion: @escaping (PlayerState) -> Void) {
        playerStateRepository.addListener(id: "state") { [self] result in
            switch result {
            case let .failure(error):
                delegate?.dataAccessProvider(self, error: .playerState(error: error))
            case let .success(playerState):
                completion(playerState)
            }
        }
    }
}
