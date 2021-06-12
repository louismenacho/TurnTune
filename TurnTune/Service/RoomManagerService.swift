//
//  RoomManagerService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/9/21.
//

import Foundation

class RoomManagerService {
    
    private(set) var roomId: String
    private var roomRepository = FirestoreRepository<Room>(collectionPath: "rooms")
    private var memberRepository: FirestoreRepository<Member>!
    private var queueRepository: FirestoreRepository<Song>!
    
    init(roomId: String) {
        self.roomId = roomId
        memberRepository = FirestoreRepository<Member>(collectionPath: "rooms/"+roomId+"/members")
        queueRepository = FirestoreRepository<Song>(collectionPath: "rooms/"+roomId+"/queue")
    }
    
    func getRoom(completion: @escaping (Result<Room, Error>) -> Void) {
        roomRepository.get(id: roomId) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(room):
                completion(.success(room))
            }
        }
    }
    
    func roomChangeListener(completion: @escaping (Result<Room, Error>) -> Void) {
        roomRepository.addListener(id: roomId) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(room):
                completion(.success(room))
            }
        }
    }
    
    func addMember(_ member: Member, completion: @escaping (Error?) -> Void) {
        memberRepository.create(member) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func listMembers(completion: @escaping (Result<[Member], Error>) -> Void) {
        memberRepository.list(memberRepository.collectionReference.order(by: "dateJoined")) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(members):
                completion(.success(members))
            }
        }
    }
    
    func membersChangeListener(completion: @escaping (Result<[Member], Error>) -> Void) {
        memberRepository.addListener(memberRepository.collectionReference.order(by: "dateJoined")) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(members):
                completion(.success(members))
            }
        }
    }
    
    func queueSong(_ song: Song, completion: @escaping (Error?) -> Void) {
        queueRepository.create(song) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func listQueue(queueMode: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        var query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: false).order(by: "orderGroup").order(by: "dateAdded")
        if queueMode == "FIFO" {
            query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: false).order(by: "dateAdded")
        }
        
        queueRepository.list(query) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(queue):
                completion(.success(queue))
            }
        }
    }
    
    func queueChangeListener(queueMode: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        var query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: false).order(by: "orderGroup").order(by: "dateAdded")
        if queueMode == "FIFO" {
            query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: false).order(by: "dateAdded")
        }
        
        queueRepository.addListener(query) { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queue):
                completion(.success(queue))
            }
        }
    }
}
