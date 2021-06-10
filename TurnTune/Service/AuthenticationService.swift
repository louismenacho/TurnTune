//
//  AuthenticationService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/3/21.
//

import Foundation
import FirebaseAuth

protocol AuthenticationService {
    associatedtype User
    
    func signIn(displayName: String, completion: @escaping (Result<User, Error>) -> Void)
    func setDisplayName(_ displayName: String, completion: @escaping (Error?) -> Void)
    func signOut(completion: @escaping (Error?) -> Void)
    
}

class FirebaseAuthService: AuthenticationService {
    
    private(set) var auth = Auth.auth()
    
    func signIn(displayName: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signInAnonymously { [self] (authDataResult, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let authData = authDataResult {
                setDisplayName(displayName) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(authData.user))
                    }
                }
            }
        }
    }
    
    func setDisplayName(_ displayName: String, completion: @escaping (Error?) -> Void) {
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges { error in
            completion(error)
        }
    }
    
    func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try auth.signOut()
        } catch {
            completion(error)
        }
    }
    
    func addStateDidChangeListener(completion: @escaping (Result<Auth, Error>) -> Void) {
        auth.addStateDidChangeListener { auth, user in
            completion(.success(auth))
        }
    }
    
    func isSignedIn() -> Bool {
        return auth.currentUser != nil
    }
    
    private func isNameValid(name: String) -> Bool {
        if name.isEmpty || name.count > 12 {
            print("Invalid name")
            return false
        }
        return true
    }
    
}

class RoomManagerService {
    
    private(set) var roomId: String
    private(set) var memberRepository: FirestoreRepository<Member>!
    private(set) var queueRepository: FirestoreRepository<Song>!
    
    init(roomId: String) {
        self.roomId = roomId
        memberRepository = FirestoreRepository<Member>(collectionPath: "rooms/"+roomId+"/members")
        queueRepository = FirestoreRepository<Song>(collectionPath: "rooms/"+roomId+"/queue")
    }
    
    func getMember(memberId: String, completion: @escaping (Result<Member, Error>) -> Void) {
        memberRepository.get(id: memberId) { (result: Result<Member, Error>) in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(member):
                completion(.success(member))
            }
        }
    }
    
    func addMember(member: Member, completion: @escaping (Error?) -> Void) {
        memberRepository.create(member) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func addSong(song: Song, completion: @escaping (Error?) -> Void) {
        queueRepository.create(song) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

class RoomProviderService {
    
    private var repository = FirestoreRepository<Room>(collectionPath: "rooms")
    
    func getExistingRoom(roomId: String, completion: @escaping (Result<Room, Error>) -> Void) {
        repository.get(id: roomId) { (result: Result<Room, Error>) in
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
        repository.create(newRoom) { error in
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

