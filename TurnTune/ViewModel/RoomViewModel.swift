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
    
    // Firestore
    private(set) var database = FirestoreDatabase()
    private(set) var roomDocumentRef: DocumentReference
    private(set) var membersCollectionRef: CollectionReference
    
    // Models
    private(set) var room: Room!
    private(set) var members: [Member]!
    
    // Service
    private var spotifyPlayer: SpotifyPlayer { SpotifyPlayer.shared }
    
    // Computed
    var currentMember: Member? { members.first { $0.uid == Auth.auth().currentUser?.uid } }
    var isCurrentMemberTurn: Bool { members[room.turn].uid == Auth.auth().currentUser?.uid }
    
    init(_ roomDocumentRef: DocumentReference) {
        self.roomDocumentRef = roomDocumentRef
        membersCollectionRef = roomDocumentRef.collection("members")
        SpotifySessionManager.shared.initiateSession()
        spotifyPlayer.delegate = self
        getFirestoreData(completion:) {
            self.addFirestoreListeners()
        }
    }
    
    private func getFirestoreData(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        database.getDocumentData(documentRef: roomDocumentRef) { (room: Room) in
            self.room = room
            group.leave()
        }
        
        group.enter()
        database.getCollectionData(query: membersCollectionRef.order(by: "dateJoined")) { (members: [Member]) in
            self.members = members
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.delegate?.roomViewModel(roomViewModel: self, didInitialize: true)
            completion()
        }
    }
    
    private func addFirestoreListeners() {
        database.addDocumentListener(documentRef: roomDocumentRef) { (room: Room) in
            self.room = room
            self.delegate?.roomViewModel(roomViewModel: self, didUpdate: room)
        }
        database.addCollectionListener(query: membersCollectionRef.order(by: "dateJoined")) { (members: [Member]) in
            self.members = members
            if self.room.isAwaitingSongSelection, let selectedSong = self.members[self.room.turn].selectedSong {
                self.play(selectedSong) {
                    self.deleteMemberSelectedSong(for: self.currentMember!)
                }
            }
            self.delegate?.roomViewModel(roomViewModel: self, didUpdate: members)
        }
    }
    
    func incrementRoomTurn(completion: @escaping (Int) -> Void) {
        var room = self.room!
        room.turn = room.turn == members.count - 1 ? 0 : room.turn + 1
        database.setDocumentData(from: room, in: roomDocumentRef) {
            completion(room.turn)
        }
    }
    
    func setIsRoomAwaitingSongSelection(_ flag: Bool, completion: ((Bool) -> Void)? = nil) {
        var room = self.room!
        room.isAwaitingSongSelection = flag
        #warning("check to not save the same value multiple times)")
        database.setDocumentData(from: room, in: roomDocumentRef) {
            completion?(self.room.isAwaitingSongSelection)
        }
    }
    
    func setRoomPlayingSong(_ song: Song, completion: (() -> Void)? = nil) {
        var room = self.room!
        room.playingSong = members[room.turn].selectedSong
        self.database.setDocumentData(from: room, in: roomDocumentRef) {
            completion?()
        }
    }
    
    func setMemberSelectedSong(_ song: Song, for member: Member, completion: ((Song) -> Void)? = nil) {
        var member = member
        member.selectedSong = song
        database.setDocumentData(from: member, in: membersCollectionRef.document(member.uid)) {
            completion?(song)
        }
    }

    func deleteMemberSelectedSong(for member: Member, completion: (() -> Void)? = nil) {
        var member = member
        member.selectedSong = nil
        database.setDocumentData(from: member, in: membersCollectionRef.document(member.uid)) {
            completion?()
        }
    }
    
    // Spotify Player Methods
        
    func play(_ song: Song, completion: (() -> Void)? = nil) {
        self.setIsRoomAwaitingSongSelection(false)
        spotifyPlayer.playTrack(uri: song.spotifyURI!)
    }
    
    func pause(completion: (() -> Void)? = nil) {
        spotifyPlayer.pausePlayback() {
            completion?()
        }
    }
    
    // Chain functions
    
    func setAndPlaySelectedSong(_ song: Song, for member: Member) {
        setMemberSelectedSong(song, for: member) { selectedSong in
            self.play(selectedSong)
        }
    }
    
    func incrementTurnAndPlayNextSong() {
        self.deleteMemberSelectedSong(for: self.members[room.turn])
        incrementRoomTurn() { newTurn in
            let turnMember = self.members[newTurn]
            guard let nextSong = turnMember.selectedSong else {
                print("Spotify paused, turn member did not select song")
                self.setIsRoomAwaitingSongSelection(true)
                return
            }
            self.play(nextSong)
        }
    }
}

extension RoomViewModel: SpotifyPlayerDelegate {
    func spotifyPlayer(spotifyPlayer: SpotifyPlayer, didChangeTrack track: SPTAppRemoteTrack) {
        setRoomPlayingSong(Song(spotifyTrack: track))
    }
    
    func spotifyPlayer(spotifyPlayer: SpotifyPlayer, didFinishTrack track: SPTAppRemoteTrack) {
        incrementTurnAndPlayNextSong()
    }
}
