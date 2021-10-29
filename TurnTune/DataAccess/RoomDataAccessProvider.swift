//
//  RoomDataAccessProvider.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/18/21.
//

import Foundation

class RoomDataAccessProvider: DataAccessProvider {
    
    weak var delegate: DataAccessProviderDelegate?
        
    var currentRoomID: String {
        return UserDefaultsRepository().roomID
    }
    
    private var roomRepository = {
        FirestoreRepository<Room>(collectionPath: "rooms")
    }()
    
    func createRoom(host user: Member, completion: ((Room) -> Void)? = nil) {
        getNewRoomCode { [self] roomCode in
            let newRoom = Room(roomCode, host: user)
            roomRepository.create(newRoom) { [self] error in
                if let error = error {
                    delegate?.dataAccessProvider(self, error: .room(error: error))
                } else {
                    completion?(newRoom)
                }
            }
        }
    }
    
    func updateRoom(_ room: Room, completion: (() -> Void)? = nil) {
        roomRepository.update(room) { [self] error in
            if let error = error {
                delegate?.dataAccessProvider(self, error: .room(error: error))
            } else {
                completion?()
            }
        }
    }
    
    func getRoom(_ roomID: String? = nil, completion: @escaping (Room?) -> Void) {
        roomRepository.get(id: roomID ?? currentRoomID) { [self] result in
            switch result {
            case let .failure(error):
                    if case .notFound = error as? RepositoryError {
                        completion(nil)
                    } else {
                        delegate?.dataAccessProvider(self, error: .room(error: error))
                    }
            case let .success(room):
                completion(room)
            }
        }
    }
    
    func roomChangeListener(completion: @escaping (Room) -> Void) {
        roomRepository.addListener(id: currentRoomID) { [self] result in
            switch result {
            case let .failure(error):
                delegate?.dataAccessProvider(self, error: .room(error: error))
            case let .success(room):
                completion(room)
            }
        }
    }
    
    func removeListener() {
        roomRepository.removeListener()
    }
    
    private func isRoomCodeValid(code: String) -> Bool {
        if code.isEmpty || code.count != 4 {
            print("Invalid code")
            return false
        }
        return true
    }
    
    private func getNewRoomCode(completion: @escaping (String) -> Void) {
        let newRoomCode = generateFourDigitRoomCode()
        getRoom(newRoomCode) { room in
            if room == nil {
                print("\(newRoomCode) does not exist. Using for new room")
                completion(newRoomCode)
            } else {
                print("\(newRoomCode) already exists. Regenerating room code")
                self.getNewRoomCode(completion: completion)
            }
        }
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
