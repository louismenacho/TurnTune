//
//  RoomService.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/18/21.
//

import Foundation

class RoomService {
    
    private var roomRepository = {
        FirestoreRepository<Room>(collectionPath: "rooms")
    }()
    
    private var userDefaultsRepository = {
        UserDefaultsRepository()
    }()
    
    var currentRoomID: String {
        userDefaultsRepository.roomID
    }
    
    func createRoom(host user: Member, completion: @escaping (Result<Room, Error>) -> Void) {
        let newRoomCode = generateFourDigitRoomCode()
        let newRoom = Room(newRoomCode, host: user)
        roomRepository.create(newRoom) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(newRoom))
            }
        }
    }
    
    func updateRoom(_ room: Room, completion: @escaping (Error?) -> Void) {
        roomRepository.update(room) { error in
            completion(error)
        }
    }

    
    func getRoom(_ roomID: String, completion: @escaping (Result<Room, Error>) -> Void) {
        roomRepository.get(id: roomID) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(room):
                completion(.success(room))
            }
        }
    }
    
    func getCurrentRoom(completion: @escaping (Result<Room, Error>) -> Void) {
        roomRepository.get(id: currentRoomID) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(room):
                completion(.success(room))
            }
        }
    }
    
    func roomChangeListener(completion: @escaping (Result<Room, Error>) -> Void) {
        roomRepository.addListener(id: currentRoomID) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(room):
                completion(.success(room))
            }
        }
    }
    
    func saveRoomID(_ roomID: String) {
        userDefaultsRepository.roomID = roomID
    }
    
    private func isRoomCodeValid(code: String) -> Bool {
        if code.isEmpty || code.count != 4 {
            print("Invalid code")
            return false
        }
        return true
    }

    private func generateFourDigitRoomCode() -> String {
        let alphabeticRange = 65...90
        var code = ""
        while code.count < 4 {
            let unicodeScalar = Int.random(in: alphabeticRange)
            let letter = Character(UnicodeScalar(unicodeScalar)!)
            code = "\(code)\(letter)"
        }
        return code
    }
    
}
