//
//  QueueViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/1/21.
//

import Foundation

class QueueViewModel {
    
    private(set) var queueRepository: FirestoreRepository<Song>
    
    private(set) var queue = [Song]()
    
    init(roomId: String, queueMode: String) {
        queueRepository = FirestoreRepository<Song>(collectionPath: "rooms/"+roomId+"/queue")

        var query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: false).order(by: "orderGroup").order(by: "dateAdded")
        if queueMode == "FIFO" {
            query = queueRepository.collectionReference.whereField("didPlay", isEqualTo: false).order(by: "dateAdded")
        }

        queueRepository.list(query) { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queue):
                self.queue = queue
            }
        }
        
        queueRepository.addListener(query) { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queue):
                self.queue = queue
            }
        }
    }
}
