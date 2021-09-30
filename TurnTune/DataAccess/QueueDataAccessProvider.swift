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
    
    private var queueRepository: FirestoreRepository<QueueItem> {
        let roomID = UserDefaultsRepository().roomID
        return FirestoreRepository<QueueItem>(collectionPath: "rooms/"+roomID+"/queue")
    }
     
    func addItem(_ item: QueueItem, completion: (() -> Void)? = nil) {
        queueRepository.create(item) { [self] error in
            if let error = error {
                delegate?.dataAccessProvider(self, error: .queue(error: error))
            } else {
                completion?()
            }
        }
    }
    
    func markDidPlay(_ item: QueueItem, completion: (() -> Void)? = nil) {
        var item = item
        item.didPlay = true
        updateItem(item) {
            completion?()
        }
    }
    
    func removeItem(_ item: QueueItem, completion: (() -> Void)? = nil) {
        queueRepository.delete(item) { [self] error in
            if let error = error {
                delegate?.dataAccessProvider(self, error: .queue(error: error))
            } else {
                completion?()
            }
        }
    }
    
    func updateItem(_ item: QueueItem, completion: (() -> Void)? = nil) {
        queueRepository.update(item) { [self] error in
            if let error = error {
                delegate?.dataAccessProvider(self, error: .queue(error: error))
            } else {
                completion?()
            }
        }
    }
    
    func listQueue(queueMode: QueueType, didPlayFlag: Bool = false, completion: @escaping ([QueueItem]) -> Void) {
        var query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: didPlayFlag)
        
        switch queueMode {
            case .fair:
                query = query.order(by: "priority").order(by: "dateAdded")
            case .ordered:
                query = query.order(by: "dateAdded")
        }
        
        queueRepository.list(query) { [self] result in
            switch result {
            case let .failure(error):
                delegate?.dataAccessProvider(self, error: .queue(error: error))
            case let .success(queue):
                completion(queue)
            }
        }
    }
    
    func queueChangeListener(queueMode: QueueType, didPlayFlag: Bool = false, completion: @escaping ([QueueItem]) -> Void) {
        var query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: didPlayFlag)
        
        switch queueMode {
            case .fair:
                query = query.order(by: "priority").order(by: "dateAdded")
            case .ordered:
                query = query.order(by: "dateAdded")
        }
        
        queueRepository.addListener(query) { [self] result in
            switch result {
            case let .failure(error):
                delegate?.dataAccessProvider(self, error: .queue(error: error))
            case let .success(queue):
                completion(queue)
            }
        }
    }
    
    func removeListener() {
        queueRepository.removeListener()
    }
    
}
