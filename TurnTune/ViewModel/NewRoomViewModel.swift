//
//  NewRoomViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/31/21.
//

import Foundation

class NewRoomViewModel {
    
    private var authentication = FirebaseAuthService()
    private(set) var roomManager: RoomManagerService
    
    private(set) var room: Room?
    private(set) var memberList = [Member]()
    private(set) var queue = [Song]()
    
    private var spotifySessionManager = SpotifySessionManager.shared
    private var spotifyAppRemote = SpotifyAppRemote.shared
    private var spotifyWebAPI = SpotifyAPI.shared
    
    init(roomManager: RoomManagerService) {
        self.roomManager = roomManager
        loadRoom { room in
            if room.hostId == self.authentication.currentUser()?.uid {
                self.spotifySessionManager.initiateSession()
                self.spotifyAppRemote.delegate = self
            }
        }
    }
    
    func loadRoom(completion: @escaping (Room) -> Void) {
        roomManager.getRoom { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(room):
                self.room = room
                completion(room)
            }
        }
    }
    
    func roomChangeListener(completion: @escaping (Room) -> Void) {
        roomManager.roomChangeListener { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(room):
                self.room = room
                completion(room)
            }
        }
    }
    
    func loadMemberList(completion: @escaping ([Member]) -> Void) {
        roomManager.listMembers { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(memberList):
                self.memberList = memberList
                completion(memberList)
            }
        }
    }
    
    func memberListChangeListener(completion: @escaping ([Member]) -> Void) {
        roomManager.membersChangeListener { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(memberList):
                self.memberList = memberList
                completion(memberList)
            }
        }
    }
    
    func loadQueue(completion: @escaping ([Song]) -> Void) {
        roomManager.listQueue(queueMode: room?.id ?? "") { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queue):
                self.queue = queue
                completion(queue)
            }
        }
    }
    
    func queueChangeListener(completion: @escaping ([Song]) -> Void) {
        roomManager.queueChangeListener(queueMode: room?.id ?? "") { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queue):
                self.queue = queue
                completion(queue)
            }
        }
    }
    
    func queueSong(_ song: Song) {
        var newSong = song
        newSong.orderGroup = queue.filter({ $0.addedBy?.id == authentication.currentUser()?.uid }).count
        newSong.addedBy = memberList.first { $0.id == authentication.currentUser()?.uid }
        roomManager.queueSong(newSong) { error in
            if let error = error {
                print(error)
            }
        }
    }
}

extension NewRoomViewModel: SpotifyAppRemoteDelegate {
    func spotifyAppRemote(spotifyAppRemote: SpotifyAppRemote, trackDidChange newTrack: SPTAppRemoteTrack) {
        if let nextSong = queue.filter({ $0.spotifyURI == newTrack.uri }).first {
//            setRoomPlayingSong(nextSong)
        }
    }
    
    func spotifyAppRemote(spotifyAppRemote: SpotifyAppRemote, trackDidFinish track: SPTAppRemoteTrack) {
        print(queue.count)
        if !queue.isEmpty {
            let song = queue.removeFirst()
//            play(song) {
//                Firestore.firestore().document(self.queueCollectionPath+"/"+song.id!).delete()
//            }
        }
    }
}
