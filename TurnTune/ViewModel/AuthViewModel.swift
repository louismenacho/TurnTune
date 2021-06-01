//
//  AuthViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/8/21.
//

import Foundation
import Firebase

class AuthViewModel {
    
    private(set) var roomPath: String = ""
    
    private(set) var auth = FirebaseAuth.shared
//    private(set) var firestore = FirebaseFirestore.shared
    
    lazy private(set) var roomCode: String = { generateRoomCode() }()
    lazy private(set) var memberRepository = FirestoreRepository<Member>(reference: "rooms/"+roomCode+"/members")
    private(set) var roomRepository = FirestoreRepository<Room>(reference: "rooms")
    
    func join(room code: String, displayName: String, completion: @escaping () -> Void) {
        guard isRoomCodeValid(code: code) && isNameValid(name: displayName) else {
            return
        }
        signIn(as: displayName) { [self] user in
            getRoom(code: code) { room in
                let newMember = Member(id: user.uid, displayName: displayName)
                createRoomMember(newMember) {
                    roomPath = "rooms/"+code
                    completion()
                }
            }
        }
    }
    
    func host(displayName: String, completion: @escaping () -> Void) {
        guard isNameValid(name: displayName) else { return }
//        let roomCode = generateRoomCode()
        
        signIn(as: displayName) { [self] user in
            let newMember = Member(id: user.uid, displayName: user.displayName!)
            let newRoom = Room(id: roomCode, hostId: user.uid)
            createRoom(newRoom) { room in
                createRoomMember(newMember) {
                    roomPath = "rooms/"+roomCode
                    completion()
                }
            }
        }
    }
    
    func signIn(as displayName: String, completion: @escaping (User) -> Void) {
        auth.signInAnonymously { [self] result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(authData):
                auth.setDisplayName(displayName, for: authData.user) { error in
                    completion(authData.user)
                }
            }
        }
    }
    
    func getRoom(code: String, completion: @escaping (Room) -> Void) {
//        firestore.getDocumentData(documentPath: "rooms/"+code) { (result: Result<Room, Error>) in
//            switch result {
//            case let .failure(error):
//                print(error)
//            case let .success(room):
//                completion(room)
//            }
//        }
        roomRepository.get(id: code) { (result: Result<Room, Error>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(room):
                completion(room)
            }
        }
    }
    
    func createRoom(_ room: Room, completion: @escaping (Room) -> Void) {
//        firestore.setData(from: room, in: "rooms/"+room.id) { error in
//            if let error = error {
//                print(error)
//            }
//            completion(room)
//        }
        roomRepository.create(room) { error in
            if let error = error {
                print("error on roomRepository.create:")
                print(error)
            }
            completion(room)
        }
    }
    
    func createRoomMember(_ member: Member, completion: @escaping () -> Void) {
//        firestore.setData(from: member, in: "rooms/"+room.id+"/members/"+member.uid) { error in
//            if let error = error {
//                print(error)
//            }
//            completion()
//        }
        memberRepository.create(member) { error in
            if let error = error {
                print(error)
            }
            completion()
        }
    }
    
    private func isRoomCodeValid(code: String) -> Bool {
        if code.isEmpty || code.count != 4 {
            print("Invalid code")
            return false
        }
        return true
    }
    
    private func isNameValid(name: String) -> Bool {
        if name.isEmpty {
            print("Invalid name")
            return false
        }
        return true
    }
    
    private func generateRoomCode() -> String {
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
