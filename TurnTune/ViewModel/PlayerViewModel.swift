//
//  PlayerViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/21/21.
//

import Foundation

class PlayerViewModel {
    
    private(set) var authService = FirebaseAuthService()
    private(set) var musicPlayerService: SpotifyMusicPlayerService
    private(set) var playerStateDataAccess = PlayerStateDataAccessProvider()
    private(set) var queueDataAccess = QueueDataAccessProvider()
    
    var playerState = PlayerState()
    var queue = [QueueItem]()
    var history = [QueueItem]()
    
    init(musicPlayerService: SpotifyMusicPlayerService) {
        self.musicPlayerService = musicPlayerService
        self.musicPlayerService.playerStateChangeListener { [self] playerState in
            playerStateDataAccess.updatePlayerState(playerState)
        }
    }
    
    func loadPlayerState(completion: @escaping (PlayerState) -> Void) {
        playerStateDataAccess.getPlayerState{ result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(playerState):
                self.playerState = playerState
            }
        }
    }
    
    func playerStateChangeListener(completion: @escaping (PlayerState) -> Void) {
        playerStateDataAccess.playerStateChangeListener { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(playerState):
                self.playerState = playerState
            }
        }
    }
    
    func loadQueue(completion: @escaping ([QueueItem]) -> Void) {
        queueDataAccess.listQueue(queueMode: .fair) { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queue):
                self.queue = queue
                completion(queue)
            }
        }
    }
    
    func queueChangeListener(completion: @escaping ([QueueItem]) -> Void) {
        queueDataAccess.queueChangeListener(queueMode: .fair) { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queue):
                self.queue = queue
                completion(queue)
            }
        }
    }
    
    func loadQueueHistory(completion: @escaping ([QueueItem]) -> Void) {
        queueDataAccess.listQueue(queueMode: .fair, didPlayFlag: true) { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(queueHistory):
                self.history = queueHistory.reversed()
                completion(queueHistory)
            }
        }
    }
    
    func queueHistoryChangeListener(completion: @escaping ([QueueItem]) -> Void) {
        queueDataAccess.queueChangeListener(queueMode: .fair, didPlayFlag: true) { result in
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
        var item = QueueItem(song: song)
        item.priority = queue.filter({ $0.addedBy.userID == authService.currentUserID }).count
        item.addedBy.userID = authService.currentUserID
        queueDataAccess.addItem(item) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func removeFromQueue(_ item: QueueItem, completion: (() -> Void)? = nil) {
        queueDataAccess.removeItem(item) { error in
            if let error = error {
                print(error)
            } else {
                completion?()
            }
        }
    }
    
    // MARK: - Host Methods
    
    func play(_ items: [QueueItem]? = nil, position: Int = 0, completion: (() -> Void)? = nil ) {
        musicPlayerService.startPlayback(songs: items?.compactMap { $0.song }, position: position) {
            print("playing \(items?.compactMap { $0.song.name } ?? [])")
            completion?()
        }
    }
    
    func resumeQueue(completion: (() -> Void)? = nil) {
        if playerState.isRadio {
            playNextSong {
                completion?()
            }
        }
    }
    
    func playNextSong(completion: (() -> Void)? = nil) {
        guard let nextSong = queue.first else {
            return
        }
        play([nextSong]) { [self] in
            removeFromQueue(nextSong) {
                completion?()
            }
        }
    }
    
    func pause(completion: (() -> Void)? = nil) {
        musicPlayerService.pausePlayback {
            completion?()
        }
    }
    
    func startQueue(completion: (() -> Void)? = nil) {
        musicPlayerService.initiate { [self] in
            playNextSong {
                completion?()
            }
        }
    }
    
    func rewindSong(completion: (() -> Void)? = nil) {
        musicPlayerService.rewindPlayback {
            completion?()
        }
    }
    
}

extension PlayerViewModel: MusicPlayerServiceableDelegate  {
//    func musicPlayerServiceable(playbackDidStart playerState: PlayerState) {
//        print("playbackDidStart")
//        playerStateDataAccess.updatePlayerState(playerState) { _ in }
//    }
//
//    func musicPlayerServiceable(playbackDidPause playerState: PlayerState) {
//        print("playbackDidPause")
//        playerStateDataAccess.updatePlayerState(playerState) { _ in }
//    }
//
//    func musicPlayerServiceable(playbackDidChange playerState: PlayerState) {
//        print("playbackDidChange")
//        playerStateDataAccess.updatePlayerState(playerState) { _ in }
//    }
//
//    func musicPlayerServiceable(playbackDidFinish playerState: PlayerState) {
//        print("playbackDidFinish")
//        if queue.isEmpty {
//            playerStateDataAccess.updatePlayerState(playerState) { _ in }
//        } else {
//            playNextSong()
//        }
//    }
    
    func musicPlayerServiceable(error: MusicPlayerServiceableError) {
        print(error)
    }
}
