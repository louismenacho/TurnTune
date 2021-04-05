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
    private(set) var memberPath: String = ""
    
    private(set) var auth = FirebaseAuth.shared
    private(set) var firestore = FirebaseFirestore.shared
    
    func join(room code: String, displayName: String, completion: @escaping () -> Void) {
        guard isRoomCodeValid(code: code) && isNameValid(name: displayName) else {
            return
        }
        signIn(as: displayName) { [self] user in
            getRoom(code: code) { room in
                let newMember = Member(uid: user.uid, displayName: displayName)
                appendMember(newMember, to: room) {
                    roomPath = "rooms/"+room.code
                    memberPath = roomPath+"/members/"+newMember.uid
                    completion()
                }
            }
        }
    }
    
    func host(displayName: String, completion: @escaping () -> Void) {
        guard isNameValid(name: displayName) else { return }
        let roomCode = generateRoomCode()
        
        signIn(as: displayName) { [self] user in
            let newMember = Member(uid: user.uid, displayName: user.displayName!)
            let newRoom = Room(code: roomCode, host: newMember)
            createRoom(newRoom) { room in
                appendMember(newMember, to: newRoom) {
                    roomPath = "rooms/"+room.code
                    memberPath = roomPath+"/members/"+newMember.uid
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
        firestore.getDocumentData(documentPath: "rooms/"+code) { (result: Result<Room, Error>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(room):
                completion(room)
            }
        }
    }
    
    func createRoom(_ room: Room, completion: @escaping (Room) -> Void) {
        firestore.setData(from: room, in: "rooms/"+room.code) { error in
            if let error = error {
                print(error)
            }
            completion(room)
        }
    }
    
    func appendMember(_ member: Member, to room: Room, completion: @escaping () -> Void) {
        firestore.setData(from: member, in: "rooms/"+room.code+"/members/"+member.uid) { error in
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
