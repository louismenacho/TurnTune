//
//  NewRoomViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/31/21.
//

import Foundation

class NewRoomViewModel: RepoViewModel {
    
    private(set) var roomRepository: FirestoreRepository<Room>
    
    private(set) var room: Room?
    
    required init(repository: FirestoreRepository<Room>) {
        roomRepository = repository
    }
    
    func loadRoom(roomId: String, completion: @escaping (Result<Room, Error>) -> Void) {
        roomRepository.get(id: roomId) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(room):
                self.room = room
                completion(.success(room))
            }
        }
    }
    
    func registerRoomListener(roomId: String, completion: @escaping (Result<Room, Error>) -> Void) {
        roomRepository.addListener(id: roomId) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(room):
                self.room = room
                completion(.success(room))
            }
        }
    }
}
