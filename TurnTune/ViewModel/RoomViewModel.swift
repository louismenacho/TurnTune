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
    private(set) var database = FirebaseFirestore.shared
    private(set) var roomPath: String
    private(set) var membersCollectionPath: String
    
    // Models
    private(set) var room: Room!
    private(set) var members: [Member]!
    
    // Service
    private var spotifyPlayer: SpotifyPlayer { SpotifyPlayer.shared }
    
    // Computed
    var currentMember: Member? { members.first { $0.uid == Auth.auth().currentUser?.uid } }
    var isCurrentMemberTurn: Bool { members[room.turn].uid == Auth.auth().currentUser?.uid }
    
    init(roomPath: String) {
        self.roomPath = roomPath
        membersCollectionPath = roomPath+"/members"
        loadFirestoreData(completion:) {
            self.addFirestoreListeners()
        }
        
        SpotifySessionManager.shared.initiateSession()
        spotifyPlayer.delegate = self
    }
    
    private func loadFirestoreData(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        database.getDocumentData(documentPath: roomPath) { (result: Result<Room, Error>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(room):
                self.room = room
            }
            group.leave()
        }
        
        group.enter()
        database.getCollectionData(collectionPath: membersCollectionPath, orderBy: "dateJoined") { (result: Result<[Member], Error>) in
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
        database.addDocumentListener(documentPath: roomPath) { (result: Result<Room, Error>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(room):
                self.room = room
                self.delegate?.roomViewModel(roomViewModel: self, didUpdate: room)
            }
        }
        database.addCollectionListener(collectionPath: membersCollectionPath, orderBy: "dateJoined") { (result: Result<[Member], Error>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(members):
                self.members = members
                self.delegate?.roomViewModel(roomViewModel: self, didUpdate: members)
            }
        }
    }
    
    func incrementRoomTurn(completion: @escaping (Int) -> Void) {
        var room = self.room!
        room.turn = room.turn == members.count - 1 ? 0 : room.turn + 1
        database.setData(from: room, in: roomPath) { error in
            completion(room.turn)
        }
    }
    
    func setRoomPlayingSong(_ song: Song, completion: (() -> Void)? = nil) {
        var room = self.room!
        room.playingSong = members[room.turn].selectedSong
        self.database.setData(from: room, in: roomPath) { error in
            completion?()
        }
    }
    
    func setMemberSelectedSong(_ song: Song, for member: Member, completion: ((Song) -> Void)? = nil) {
        var member = member
        member.selectedSong = song
        database.setData(from: member, in: membersCollectionPath+"/"+member.uid) { error in
            completion?(song)
        }
    }

    func deleteMemberSelectedSong(for member: Member, completion: (() -> Void)? = nil) {
        var member = member
        member.selectedSong = nil
        database.setData(from: member, in: membersCollectionPath+"/"+member.uid) { error in
            completion?()
        }
    }
    
    // Spotify Player Methods
        
    func play(_ song: Song, completion: (() -> Void)? = nil) {
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
