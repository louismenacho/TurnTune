//
//  RoomViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/31/21.
//

import Foundation

class RoomViewModel {
    
    private(set) var authentication = FirebaseAuthService()
    private(set) var roomManager: RoomManagerService
    private(set) var musicService: MusicServiceable
    
    private(set) var room: Room
    private(set) var memberList = [Member]()
    private(set) var queue = [Song]()
    private(set) var queueHistory = [Song]()
    
    init(roomManager: RoomManagerService, musicService: MusicServiceable) {
        self.room = roomManager.room
        self.roomManager = roomManager
        self.musicService = musicService
        self.musicService.delegate = self
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
    
    func updateRoom(_ room: Room, completion: (() -> Void)? = nil) {
        roomManager.updateRoom(room) { error in
            if let error = error {
                print(error)
            } else {
                completion?()
                print("room updated: \(room)")
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
        roomManager.listQueue(queueMode: room.id ?? "") { result in
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
        roomManager.queueChangeListener(queueMode: room.id ?? "") { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queue):
                self.queue = queue
                completion(queue)
            }
        }
    }
    
    func loadQueueHistory(completion: @escaping ([Song]) -> Void) {
        roomManager.listQueue(queueMode: room.id ?? "", didPlayFlag: true) { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queueHistory):
                self.queueHistory = queueHistory.reversed()
                completion(queueHistory)
            }
        }
    }
    
    func queueHistoryChangeListener(completion: @escaping ([Song]) -> Void) {
        roomManager.queueChangeListener(queueMode: room.id ?? "", didPlayFlag: true) { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queueHistory):
                self.queueHistory = queueHistory.reversed()
                completion(queueHistory)
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
    
    func playSong(_ song: [Song]? = nil, position: Int = 0, completion: (() -> Void)? = nil ) {
        musicService.startPlayback(songs: song, position: position) { error in
            if let error = error {
                print(error)
            } else {
                print("playing \(song?.compactMap { $0.name } ?? [])")
                completion?()
            }
        }
    }
    
    func dequeueSong(_ song: Song, completion: (() -> Void)? = nil) {
        roomManager.dequeueSong(song) { error in
            if let error = error {
                print(error)
            } else {
                print("removed \(song.name)")
            }
        }
    }
    
    func getSongRecommendations(from recentSongs: [Song], completion: @escaping ([Song]) -> Void) {
        musicService.getSongRecommendations(from: recentSongs) { (result: Result<[Song], Error>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(recommendationsResult):
                print("recommendations: \(recommendationsResult.map { $0.name })")
                completion(recommendationsResult)
            }
        }
    }
}

extension RoomViewModel: MusicServiceableDelegate {
    func musicServiceable(musicServiceable: MusicServiceable, didInitiateWith playerState: PlayerState) {
        if let lastPlayingSong = room.playerState.playingSong {
            playSong([lastPlayingSong], position: room.playerState.playbackPosition)
        }
    }
    
    func musicServiceable(musicServiceable: MusicServiceable, playingSongDidChange playerState: PlayerState) {
        print("playingSongDidChange")
        if queue.isEmpty {
            room.playerState = playerState
            updateRoom(room)
        } else {
            
        }
    }
    
    func musicServiceable(musicServiceable: MusicServiceable, playingSongDidFinish playerState: PlayerState) {
        print("playingSongDidFinish")
        if !queue.isEmpty, let nextSong = queue.first {
            dequeueSong(nextSong)
            playSong([nextSong]) { [self] in
                room.playerState.playingSong = nextSong
                updateRoom(room)
            }
        }
        else if !queueHistory.isEmpty {
            let recentSongs = Array(queueHistory.prefix(5))
            getSongRecommendations(from: recentSongs) { [self] recommendedSongs in
                playSong(recommendedSongs)
            }
        } else {
            
        }
    }
}
