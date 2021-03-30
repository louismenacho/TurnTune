//
//  CurrentUserViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/28/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol CurrentUserViewModelDelegate: class {
    func currentUserViewModel(currentUserViewModel: CurrentUserViewModel, didInitialize: Bool)
    func currentUserViewModel(currentUserViewModel: CurrentUserViewModel, didUpdate currentUser: Member)
    func currentUserViewModel(currentUserViewModel: CurrentUserViewModel, didUpdate currentUserQueue: Queue)
}

class CurrentUserViewModel: FirebaseViewModel {
    
    // Delegates
    weak var delegate: CurrentUserViewModelDelegate?
    
    // Firestore References
    private(set) var currentUserDocumentRef: DocumentReference
    private(set) var currentUserQueueDocumentRef: DocumentReference
    
    // Models
    private(set) var currentUser: Member!
    private(set) var currentUserQueue: Queue!
    
    // Computed Properties

    
    init(_ currentUserDocumentRef: DocumentReference, _ currentUserQueueDocumentRef: DocumentReference) {
        self.currentUserDocumentRef = currentUserDocumentRef
        self.currentUserQueueDocumentRef = currentUserQueueDocumentRef
        super.init()
        getFirestoreData(completion:) { self.addFirestoreListeners() }
    }
    
    private func getFirestoreData(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        getDocumentData(documentRef: currentUserDocumentRef) { (currentUser: Member) in
            self.currentUser = currentUser
            group.leave()
        }
        
        group.enter()
        getDocumentData(documentRef: currentUserQueueDocumentRef) { (currentUserQueue: Queue) in
            self.currentUserQueue = currentUserQueue
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.delegate?.currentUserViewModel(currentUserViewModel: self, didInitialize: true)
            completion()
        }
    }
    
    private func addFirestoreListeners() {
        addDocumentListener(documentRef: currentUserDocumentRef) { (currentUser: Member) in
            self.currentUser = currentUser
            self.delegate?.currentUserViewModel(currentUserViewModel: self, didUpdate: currentUser)
        }
        
        addDocumentListener(documentRef: currentUserQueueDocumentRef) { (currentUserQueue: Queue) in
            self.currentUserQueue = currentUserQueue
            self.delegate?.currentUserViewModel(currentUserViewModel: self, didUpdate: currentUserQueue)
        }
    }
    
    func appendSong(_ song: Song) {
        currentUserQueue.songs.append(song)
        try? currentUserQueueDocumentRef.setData(from: currentUserQueue)
    }
    
    func deleteSong(at index: Int) {
        currentUserQueue.songs.remove(at: index)
        try? currentUserQueueDocumentRef.setData(from: currentUserQueue)
    }
}
