//
//  RoomViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/18/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol RoomViewModelDelegate: class {
    func roomViewModel(roomViewModel: RoomViewModel, didInitialize: Bool)
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate room: Room)
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate members: [Member])
    func roomViewModel(roomViewModel: RoomViewModel, didUpdate queues: [Queue])
}

class RoomViewModel: FirestoreViewModel {
    
    // Delegates
    weak var delegate: RoomViewModelDelegate?
    
    // Firestore References
    private(set) var roomDocumentRef: DocumentReference
    private(set) var membersCollectionRef: CollectionReference
    private(set) var queuesCollectionRef: CollectionReference
    
    // Models
    private(set) var room: Room!
    private(set) var members: [Member]!
    private(set) var queues: [Queue]!
    
    // View Model Children
    private(set) var currentUserViewModel: CurrentUserViewModel
    
    // Computed Properties
    var playingSong: Song? { room.playingSong }
    var currentUser: Member { currentUserViewModel.currentUser }
    var currentUserQueue: Queue { currentUserViewModel.currentUserQueue }
    
    
    init(_ roomDocumentRef: DocumentReference) {
        self.roomDocumentRef = roomDocumentRef
        membersCollectionRef = roomDocumentRef.collection("members")
        queuesCollectionRef = roomDocumentRef.collection("queues")
        currentUserViewModel = CurrentUserViewModel(
            membersCollectionRef.document(Auth.auth().currentUser!.uid),
            queuesCollectionRef.document(Auth.auth().currentUser!.uid)
        )
        super.init()
        getFirestoreData(completion:) { self.addFirestoreListeners() }
    }
    
    private func getFirestoreData(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        getDocumentData(documentRef: roomDocumentRef) { (room: Room) in
            self.room = room
            group.leave()
        }
        
        group.enter()
        getCollectionData(query: membersCollectionRef.order(by: "dateJoined")) { (members: [Member]) in
            self.members = members
            group.leave()
        }
        
        group.enter()
        getCollectionData(query: queuesCollectionRef.order(by: "owner.dateJoined")) { (queues: [Queue]) in
            self.queues = queues
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.delegate?.roomViewModel(roomViewModel: self, didInitialize: true)
            completion()
        }
    }
    
    private func addFirestoreListeners() {
        addDocumentListener(documentRef: roomDocumentRef) { (room: Room) in
            self.room = room
            self.delegate?.roomViewModel(roomViewModel: self, didUpdate: room)
        }
        addCollectionListener(query: membersCollectionRef.order(by: "dateJoined")) { (members: [Member]) in
            self.members = members
            self.delegate?.roomViewModel(roomViewModel: self, didUpdate: members)
        }
        addCollectionListener(query: queuesCollectionRef.order(by: "owner.dateJoined")) { (queues: [Queue]) in
            self.queues = queues
            self.delegate?.roomViewModel(roomViewModel: self, didUpdate: queues)
        }
    }
    
    func appendSong(_ song: Song, to queue: Queue) {
        if queue.owner.uid == currentUser.uid {
            currentUserViewModel.appendSong(song)
        }
        else {
            var newQueue = queue
            newQueue.songs.append(song)
            try? queuesCollectionRef.document(queue.owner.uid).setData(from: newQueue)
        }
        
    }
    
    func deleteSong(from queue: Queue, at index: Int) {
        if queue.owner.uid == currentUser.uid {
            currentUserViewModel.deleteSong(at: index)
        }
        else {
            var newQueue = queue
            newQueue.songs.remove(at: index)
            try? queuesCollectionRef.document(queue.owner.uid).setData(from: newQueue)
        }
    }
}
