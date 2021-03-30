//
//  AuthViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/8/21.
//

import Foundation
import Firebase

class AuthViewModel {
    
    private(set) var roomDocumentRef: DocumentReference!
    private(set) var room: Room!
    
    private(set) var authService = AuthService()
    private(set) var firestoreDatabase = FirestoreDatabase()
    
    func join(room code: String, displayName: String, completion: (() -> Void)? = nil) {
        guard isCodeValid(code: code) && isNameValid(name: displayName) else { return }
        
        authService.signIn(displayName: displayName) { user in
            let roomDocumentRef = Firestore.firestore().collection("rooms").document(code)
            self.firestoreDatabase.getDocumentData(documentRef: roomDocumentRef) { (room: Room) in
                let newMember = Member(uid: user.uid, displayName: user.displayName!)
                
                let newMemberDocumentRef = roomDocumentRef.collection("members").document(user.uid)
                self.firestoreDatabase.setDocumentData(from: newMember, in: newMemberDocumentRef)
                
                self.roomDocumentRef = roomDocumentRef
                self.room = room
                completion?()
            }
        }
    }
    
    func host(displayName: String, completion: (() -> Void)? = nil) {
        guard isNameValid(name: displayName) else { return }
        let roomCode = generateRoomCode()
        
        authService.signIn(displayName: displayName) { user in
            let newMember = Member(uid: user.uid, displayName: user.displayName!)
            let newRoom = Room(code: roomCode, host: newMember)
            
            let newRoomDocumentRef = Firestore.firestore().collection("rooms").document(newRoom.code)
            self.firestoreDatabase.setDocumentData(from: newRoom, in: newRoomDocumentRef)
            
            let newMemberDocumentRef = newRoomDocumentRef.collection("members").document(user.uid)
            self.firestoreDatabase.setDocumentData(from: newMember, in: newMemberDocumentRef)
            
            self.roomDocumentRef = newRoomDocumentRef
            self.room = newRoom
            completion?()
        }
    }
    
    private func isCodeValid(code: String) -> Bool {
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
