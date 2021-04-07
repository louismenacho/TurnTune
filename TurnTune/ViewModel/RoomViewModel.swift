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
}

class RoomViewModel {
    
    // Delegates
    weak var delegate: RoomViewModelDelegate?
    
    // Models
    private(set) var room: Room!
    private(set) var members: [Member]!
    private(set) var queue: [Song]!
    
    // Firestore
    private(set) var roomPath: String
    private(set) lazy var membersCollectionPath = roomPath+"/members"
    private(set) lazy var queueCollectionPath = roomPath+"/queue"
    private(set) var firestore = FirebaseFirestore.shared
    
    // Spotify
    private var spotifyAppRemote = SpotifyAppRemote.shared
    private var spotifyWebAPI = SpotifyAPI.shared
    
    // Computed
    var currentMember: Member? { members.first { $0.uid == Auth.auth().currentUser?.uid } }
    var isCurrentMemberTurn: Bool { members[room.turn].uid == Auth.auth().currentUser?.uid }
    
    init(roomPath: String) {
        self.roomPath = roomPath
        loadFirestoreData(completion:) {
            self.addFirestoreListeners()
        }
        
        SpotifySessionManager.shared.initiateSession()
        spotifyAppRemote.delegate = self
    }
    
    func queueSong(_ song: Song, completion: (() -> Void)? = nil) {
        queue.append(song)
        firestore.setData(from: queue, in: queueCollectionPath) { error in
            if let error = error {
                print(error)
            }
            completion?()
        }
    }
    
    // Spotify Player Methods
        
    func play(_ song: Song, completion: (() -> Void)? = nil) {
        spotifyWebAPI.playTrack(uris: [song.spotifyURI!]) { error in
            if let error = error {
                print(error)
            }
            completion?()
        }
    }
    
    func pause(completion: (() -> Void)? = nil) {
        spotifyWebAPI.pausePlayback { error in
            if let error = error {
                print(error)
            }
            completion?()
        }
    }
    
    private func loadFirestoreData(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        firestore.getDocumentData(documentPath: roomPath) { (result: Result<Room, Error>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(room):
                self.room = room
            }
            group.leave()
        }
        
        group.enter()
        firestore.getCollectionData(collectionPath: membersCollectionPath, orderBy: "dateJoined") { (result: Result<[Member], Error>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(members):
                self.members = members
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.delegate?.roomViewModel(roomViewModel: self, didInitialize: true)
            completion()
        }
    }
    
    private func addFirestoreListeners() {
        firestore.addDocumentListener(documentPath: roomPath) { (result: Result<Room, Error>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(room):
                self.room = room
                self.delegate?.roomViewModel(roomViewModel: self, didUpdate: room)
            }
        }
        firestore.addCollectionListener(collectionPath: membersCollectionPath, orderBy: "dateJoined") { (result: Result<[Member], Error>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(members):
                self.members = members
                self.delegate?.roomViewModel(roomViewModel: self, didUpdate: members)
            }
        }
    }
}

extension RoomViewModel: SpotifyAppRemoteDelegate {
    func spotifyAppRemote(spotifyAppRemote: SpotifyAppRemote, trackDidChange track: SPTAppRemoteTrack) {
        
    }
}
