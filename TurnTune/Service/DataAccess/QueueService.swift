//
//  QueueService.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/18/21.
//

import Foundation

class QueueService {
    
    private var queueRepository: FirestoreRepository<Song> {
        FirestoreRepository<Song>(collectionPath: "rooms/"+currentRoomID+"/queue")
    }
    
    private var currentRoomID: String {
        UserDefaultsRepository().roomID
    }
        
    func addSong(_ song: Song, completion: @escaping (Error?) -> Void) {
        queueRepository.create(song) { error in
            completion(error)
        }
    }
    
    func removeSong(_ song: Song, completion: @escaping (Error?) -> Void) {
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
