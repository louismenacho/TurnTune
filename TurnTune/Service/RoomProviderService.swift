//
//  RoomProviderService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/9/21.
//

import Foundation

class RoomProviderService {
    
    private var roomRepository = FirestoreRepository<Room>(collectionPath: "rooms")
    
    func getExistingRoom(roomId: String, completion: @escaping (Result<Room, Error>) -> Void) {
        roomRepository.get(id: roomId) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(room):
                completion(.success(room))
            }
        }
    }
    
    func createNewRoom(host userId: String, completion: @escaping (Result<Room, Error>) -> Void) {
        let newRoomCode = generateFourDigitRoomCode()
        let newRoom = Room(id: newRoomCode, hostId: userId)
        roomRepository.create(newRoom) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(newRoom))
            }
        }
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
