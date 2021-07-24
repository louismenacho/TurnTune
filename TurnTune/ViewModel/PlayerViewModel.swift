//
//  PlayerViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/21/21.
//

import Foundation

class PlayerViewModel {
    
    private(set) var musicPlayerService: MusicPlayerServiceable
    private(set) var playerStateService = MusicPlayerStateService()
    private(set) var authService = FirebaseAuthService()
    private(set) var queueService = QueueService()
    
    var playerState = PlayerState()
    var queue = [Song]()
    var history = [Song]()
    
    init(musicPlayerService: MusicPlayerServiceable) {
        self.musicPlayerService = musicPlayerService
        self.musicPlayerService.initiate(delegate: self)
    }
    
    func loadPlayerState(completion: @escaping (PlayerState) -> Void) {
        playerStateService.getPlayerState{ result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(playerState):
                completion(playerState)
            }
        }
    }
    
    func playerStateChangeListener(completion: @escaping (PlayerState) -> Void) {
        playerStateService.playerStateChangeListener { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(playerState):
                completion(playerState)
            }
        }
    }
    
    func loadQueue(completion: @escaping ([Song]) -> Void) {
        queueService.listQueue(queueMode: "Fair") { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queue):
                completion(queue)
            }
        }
    }
    
    func queueChangeListener(completion: @escaping ([Song]) -> Void) {
        queueService.queueChangeListener(queueMode: "Fair") { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queue):
                completion(queue)
            }
        }
    }
    
    func loadQueueHistory(completion: @escaping ([Song]) -> Void) {
        queueService.listQueue(queueMode: "Fair", didPlayFlag: true) { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queueHistory):
                self.history = queueHistory.reversed()
                completion(queueHistory)
            }
        }
    }
    
    func queueHistoryChangeListener(completion: @escaping ([Song]) -> Void) {
        queueService.queueChangeListener(queueMode: "Fair", didPlayFlag: true) { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queueHistory):
                self.history = queueHistory.reversed()
                completion(queueHistory)
            }
        }
    }
    
    func addToQueue(_ song: Song) {
        var song = song
        song.orderGroup = queue.filter({ $0.addedBy.userID == authService.currentUser.userID }).count
        song.addedBy = authService.currentUser
        queueService.addSong(song) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func playSong(_ song: [Song]? = nil, position: Int = 0, completion: (() -> Void)? = nil ) {
        musicPlayerService.startPlayback(songs: song, position: position) { error in
            if let error = error {
                print(error)
            } else {
                print("playing \(song?.compactMap { $0.name } ?? [])")
                completion?()
            }
        }
    }
    
    func pause(completion: (() -> Void)? = nil ) {
        musicPlayerService.pausePlayback { error in
            if let error = error {
                print(error)
            } else {
                print("paused")
                completion?()
            }
        }
    }
    
}

extension PlayerViewModel: MusicPlayerServiceableDelegate  {
    func musicPlayerServiceable(playbackDidStart playerState: PlayerState) {
        print("playbackDidStart")
    }
    
    func musicPlayerServiceable(playbackDidFinish playerState: PlayerState) {
        print("playbackDidFinish")
    }
    
    func musicPlayerServiceable(playbackDidChange playerState: PlayerState) {
        print("playbackDidChange")
    }
}
