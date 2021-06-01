//
//  RemoteRepository.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/30/21.
//

import Foundation

protocol RemoteRepository {
    associatedtype Object
    associatedtype Identifier
    associatedtype RepoQuery
    
    func create(_ item: Object, completion: @escaping (Error?) -> Void)
    func update(_ item: Object, completion: @escaping (Error?) -> Void)
    func delete(_ item: Object, completion: @escaping (Error?) -> Void)
    func get(id: Identifier, completion: @escaping (Result<Object, Error>) -> Void)
    func list(_ query: RepoQuery?, completion: @escaping (Result<[Object], Error>) -> Void)
}

//class FirestoreCollectionRepository: RemoteRepository {
//
//    func get(reference: Query, completion: (Result<QuerySnapshot, Error>) -> Void) {
//
//    }
//
//    func add(_ item: QuerySnapshot, completion: (Error?) -> Void) {
//
//    }
//
//    func edit(_ item: QuerySnapshot, completion: (Error?) -> Void) {
//
//    }
//
//    func delete(_ item: QuerySnapshot, completion: (Error?) -> Void) {
//
//    }
//}

//class RoomRepository: FirestoreRepository<Room> {
//
//}
//
//class MemberRepository: Repository {
//
//    func get(reference: String, completion: (Result<Member, Error>) -> Void) {
//
//    }
//
//    func add(_ item: Member, completion: (Error?) -> Void) {
//
//    }
//
//    func edit(_ item: Member, completion: (Error?) -> Void) {
//
//    }
//
//    func delete(_ item: Member, completion: (Error?) -> Void) {
//
//    }
//}
//
//class MemberListRepository: Repository {
//
//    func get(reference: String, completion: (Result<[Member], Error>) -> Void) {
//
//    }
//
//    func add(_ item: [Member], completion: (Error?) -> Void) {
//
//    }
//
//    func edit(_ item: [Member], completion: (Error?) -> Void) {
//
//    }
//
//    func delete(_ item: [Member], completion: (Error?) -> Void) {
//
//    }
//}
//
//class SongRepository: Repository {
//
//    func get(reference: String, completion: (Result<Song, Error>) -> Void) {
//
//    }
//
//    func add(_ item: Song, completion: (Error?) -> Void) {
//
//    }
//
//    func edit(_ item: Song, completion: (Error?) -> Void) {
//
//    }
//
//    func delete(_ item: Song, completion: (Error?) -> Void) {
//
//    }
//}
//
//class QueueRepository: Repository {
//
//    func get(reference: String, completion: (Result<[Song], Error>) -> Void) {
//
//    }
//
//    func add(_ item: [Song], completion: (Error?) -> Void) {
//
//    }
//
//    func edit(_ item: [Song], completion: (Error?) -> Void) {
//
//    }
//
//    func delete(_ item: [Song], completion: (Error?) -> Void) {
//
//    }
//}

