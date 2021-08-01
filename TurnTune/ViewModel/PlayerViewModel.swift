//
//  PlayerViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/21/21.
//

import Foundation

class PlayerViewModel {
    
    private(set) var authService = FirebaseAuthService()
    private(set) var musicPlayerService: MusicPlayerServiceable
    private(set) var playerStateService = MusicPlayerStateService()
    private(set) var queueService = QueueService()
    
    var playerState = PlayerState()
    var lastStateBeforeRadio: PlayerState?
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
                self.playerState = playerState
            }
        }
    }
    
    func playerStateChangeListener(completion: @escaping (PlayerState) -> Void) {
        playerStateService.playerStateChangeListener { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(playerState):
                if self.playerState.currentSong.spotifyURI != playerState.currentSong.spotifyURI {
                    self.playerState = playerState
                    completion(playerState)
                    return
                }
                self.playerState = playerState
            }
        }
    }
    
    func loadQueue(completion: @escaping ([Song]) -> Void) {
        queueService.listQueue(queueMode: "Fair") { result in
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
        queueService.queueChangeListener(queueMode: "Fair") { result in
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
    
    func removeFromQueue(_ song: Song) {
        queueService.removeSong(song) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func play(_ song: [Song]? = nil, position: Int = 0, completion: (() -> Void)? = nil ) {
        musicPlayerService.startPlayback(songs: song, position: position) { error in
            if let error = error {
                print(error)
            } else {
                print("playing \(song?.compactMap { $0.name } ?? [])")
                completion?()
            }
        }
    }
    
    func resumeQueue(completion: (() -> Void)? = nil) {
        if playerState.isRadio {
            playNextSong()
        }
    }
    
    func playNextSong() {
        if let nextSong = queue.first {
            play([nextSong]) {
                self.removeFromQueue(nextSong)
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
        playerStateService.updatePlayerState(playerState) { _ in }
    }
    
    func musicPlayerServiceable(playbackDidChange playerState: PlayerState) {
        print("playbackDidChange")
        
        if !self.playerState.isRadio && playerState.isRadio {
            print("playing from other source")
        }
        if self.playerState.isRadio && !playerState.isRadio {
            print("resuming queue")
        }
        
        playerStateService.updatePlayerState(playerState) { _ in }
    }
    
    func musicPlayerServiceable(playbackDidFinish playerState: PlayerState) {
        print("playbackDidFinish")
        if queue.isEmpty {
            playerStateService.updatePlayerState(playerState) { _ in }
        } else {
            playNextSong()
        }
    }
}
