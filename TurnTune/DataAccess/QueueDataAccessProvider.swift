//
//  QueueDataAccessProvider.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/18/21.
//

import Foundation

enum QueueType: String, CaseIterable {
    case fair
    case ordered
}

class QueueDataAccessProvider: DataAccessProvider {
    
    weak var delegate: DataAccessProviderDelegate?
    
    private var currentRoomID: String {
        UserDefaultsRepository().roomID
    }
    
    private var queueRepository: FirestoreRepository<QueueItem> {
        FirestoreRepository<QueueItem>(collectionPath: "rooms/"+currentRoomID+"/queue")
    }
     
    func addItem(_ item: QueueItem, completion: @escaping (Error?) -> Void) {
        queueRepository.create(item) { error in
            completion(error)
        }
    }
    
    func removeItem(_ item: QueueItem, completion: @escaping (Error?) -> Void) {
        queueRepository.delete(item) { error in
            completion(error)
        }
    }
    
    func updateItem(_ item: QueueItem, completion: @escaping (Error?) -> Void) {
        queueRepository.update(item) { error in
            completion(error)
        }
    }
    
    func listQueue(queueMode: QueueType, didPlayFlag: Bool = false, completion: @escaping (Result<[QueueItem], Error>) -> Void) {
        var query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: didPlayFlag)
        
        switch queueMode {
            case .fair:
                query = query.order(by: "priority").order(by: "dateAdded")
            case .ordered:
                query = query.order(by: "dateAdded")
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
    
    func queueChangeListener(queueMode: QueueType, didPlayFlag: Bool = false, completion: @escaping (Result<[QueueItem], Error>) -> Void) {
        var query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: didPlayFlag)
        
        switch queueMode {
            case .fair:
                query = query.order(by: "priority").order(by: "dateAdded")
            case .ordered:
                query = query.order(by: "dateAdded")
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
