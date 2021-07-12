//
//  RoomManagerService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/9/21.
//

import Foundation

class RoomManagerService {
    
    private(set) var room: Room
    private var roomRepository = FirestoreRepository<Room>(collectionPath: "rooms")
    private var memberRepository: FirestoreRepository<Member>
    private var queueRepository: FirestoreRepository<Song>
    
    init?(room: Room) {
        guard let roomID = room.id else {
            print("room.id is nil")
            return nil
        }
        self.room = room
        memberRepository = FirestoreRepository<Member>(collectionPath: "rooms/"+roomID+"/members")
        queueRepository = FirestoreRepository<Song>(collectionPath: "rooms/"+roomID+"/queue")
    }
    
    func getRoom(completion: @escaping (Result<Room, Error>) -> Void) {
        roomRepository.get(id: room.id!) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(room):
                completion(.success(room))
            }
        }
    }
    
    func updateRoom(_ room: Room, completion: @escaping (Error?) -> Void) {
        roomRepository.update(room) { error in
            completion(error)
        }
    }
    
    func roomChangeListener(completion: @escaping (Result<Room, Error>) -> Void) {
        roomRepository.addListener(id: room.id!) { result in
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
            completion(error)
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
            completion(error)
        }
    }
    
    func dequeueSong(_ song: Song, completion: @escaping (Error?) -> Void) {
        var song = song
        song.didPlay = true
        queueRepository.update(song) { error in
            completion(error)
        }
    }
    
    func listQueue(queueMode: String, didPlayFlag: Bool = false, completion: @escaping (Result<[Song], Error>) -> Void) {
        var query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: didPlayFlag).order(by: "orderGroup").order(by: "dateAdded")
        if queueMode == "FIFO" {
            query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: didPlayFlag).order(by: "dateAdded")
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
    
    func queueChangeListener(queueMode: String, didPlayFlag: Bool = false, completion: @escaping (Result<[Song], Error>) -> Void) {
        var query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: didPlayFlag).order(by: "orderGroup").order(by: "dateAdded")
        if queueMode == "FIFO" {
            query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: didPlayFlag).order(by: "dateAdded")
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
