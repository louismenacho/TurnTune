//
//  OldAuthViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/7/20.
//  Copyright © 2020 Louis Menacho. All rights reserved.
//

import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore

class OldAuthViewModel {
    
    var cancellable: AnyCancellable?
    
    private(set) var roomDocumentRef: DocumentReference?
    
    private var auth: Auth { Auth.auth() }
    
    func join(room code: String, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard isCodeValid(code: code) && isNameValid(name: name) else { return }
        
        cancellable =
            self.signInAnonymously()
        .flatMap { currentUser in
            self.setDisplayName(to: name, for: currentUser)
        }
        .flatMap { currentUser in
            self.addRoomMember(user: currentUser, room: code)
        }
        .eraseToAnyPublisher()
        .sink(receiveCompletion: {
            switch $0 {
            case .failure(let error):
                completion(.failure(error))
            case .finished:
                completion(.success(()))
            }
        }, receiveValue: { roomDocumentRef in
            self.roomDocumentRef = roomDocumentRef
        })
    }
    
    func host(name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard isNameValid(name: name) else { return }
        
        cancellable =
            self.signInAnonymously()
        .flatMap { currentUser in
            self.setDisplayName(to: name, for: currentUser)
        }
        .flatMap { currentUser in
            self.createRoom(host: currentUser)
        }
        .sink(receiveCompletion: {
            switch $0 {
            case .failure(let error):
                completion(.failure(error))
            case .finished:
                completion(.success(()))
            }
        }, receiveValue: { roomDocumentRef in
            self.roomDocumentRef = roomDocumentRef
        })
    }
        
    private func signInAnonymously() -> Future<User, Error> {
        Future<User, Error> { promise in
            Auth.auth().signInAnonymously { (authResult, error) in
                if let error = error {
                    promise(.failure(error))
                } else
                if let user = authResult?.user {
                    promise(.success(user))
                }
            }
        }
    }
    
    private func setDisplayName(to name: String, for user: User) -> Future<User, Error> {
        Future<User, Error> { promise in
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(user))
                }
            }
        }
    }
    
    private func createRoom(host user: User) -> Future<DocumentReference, Error> {
        Future<DocumentReference, Error> { promise in
            do {
                let currentUser = Member(uid: user.uid, displayName: user.displayName!)
                let currentUserQueue = Queue(owner: currentUser, songs: [Song]())
                let room = Room(code: self.generateRoomCode(), host: currentUser)
                
                let roomDocumentRef = Firestore.firestore().collection("rooms").document(room.code)
                try roomDocumentRef.setData(from: room)
                
                let currentUserDocumentRef = roomDocumentRef.collection("members").document(user.uid)
                try currentUserDocumentRef.setData(from: currentUser)
                
                let currentUserQueueDocumentRef = roomDocumentRef.collection("queues").document(user.uid)
                try currentUserQueueDocumentRef.setData(from: currentUserQueue)
                
                promise(.success(roomDocumentRef))
            } catch {
                promise(.failure(error))
            }
        }
    }
    
    private func addRoomMember(user: User, room code: String) -> Future<DocumentReference, Error> {
        Future<DocumentReference, Error> { promise in
            let roomDocumentRef = Firestore.firestore().collection("rooms").document(code)
            roomDocumentRef.getDocument { (document, error) in
                if let error = error {
                    promise(.failure(error))
                }
                guard let roomDocument = document, roomDocument.exists else {
                    promise(.failure(TurnTuneError.invalidRoomCode))
                    return
                }
                do {
                    let currentUser = Member(uid: user.uid, displayName: user.displayName!)
                    let currentUserQueue = Queue(owner: currentUser,songs: [Song]())
                    
                    let currentUserDocumentRef = roomDocumentRef.collection("members").document(user.uid)
                    try currentUserDocumentRef.setData(from: currentUser)
                    
                    let currentUserQueueDocumentRef = roomDocumentRef.collection("queues").document(user.uid)
                    try currentUserQueueDocumentRef.setData(from: currentUserQueue)
                    
                    promise(.success(roomDocumentRef))
                } catch {
                    promise(.failure(error))
                }

                promise(.success(roomDocumentRef))
            }
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
