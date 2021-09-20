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
        self.playerStateDataAccess.delegate = self
        self.queueDataAccess.delegate = self
    }
    
    func playerStateChangeListener(completion: @escaping (PlayerState) -> Void) {
        playerStateDataAccess.playerStateChangeListener { [self] playerState in
            self.playerState = playerState
            completion(playerState)
        }
    }
    
    func queueChangeListener(completion: @escaping ([QueueItem]) -> Void) {
        queueDataAccess.queueChangeListener(queueMode: .fair) { [self] queue in
            self.queue = queue
            completion(queue)
        }
    }
    
    func queueHistoryChangeListener(completion: @escaping ([QueueItem]) -> Void) {
        queueDataAccess.queueChangeListener(queueMode: .fair, didPlayFlag: true) { [self] queueHistory in
            self.history = queueHistory.reversed()
            completion(queueHistory)
        }
    }
    
    func updatePlayerState(_ playerState: PlayerState, completion: (() -> Void)? = nil) {
        playerStateDataAccess.updatePlayerState(playerState) {
            completion?()
        }
    }
    
    func addToQueue(_ song: Song, completion: (() -> Void)? = nil) {
        var item = QueueItem(song: song)
        item.priority = queue.filter({ $0.addedBy.userID == authService.currentUserID }).count
        item.addedBy.userID = authService.currentUserID
        queueDataAccess.addItem(item) {
            completion?()
        }
    }
    
    func removeFromQueue(_ item: QueueItem, completion: (() -> Void)? = nil) {
        queueDataAccess.markDidPlay(item) {
            completion?()
        }
    }
    
    // MARK: - Host Methods
    
    func play(_ items: [QueueItem]? = nil, position: Int = 0, completion: (() -> Void)? = nil ) {
        musicPlayerService.startPlayback(songs: items?.compactMap { $0.song }, position: position) { error in
            print("playing \(items?.compactMap { $0.song.name } ?? [])")
            completion?()
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
        musicPlayerService.pausePlayback { error in
            completion?()
        }
    }
    
    func startQueue(completion: (() -> Void)? = nil) {
        guard let firstItem = queue.first else {
            return
        }
        musicPlayerService.initiateSession(playing: firstItem.song) { [self] in
            removeFromQueue(firstItem) {
                completion?()
            }
        }
        musicPlayerService.playerStateChangeListener { [self] newPlayerState in
            if playerState != newPlayerState {
                if newPlayerState.didFinish {
                    playNextSong()
                } else {
                    updatePlayerState(newPlayerState)
                }
            }
        }

    }
    
    func rewindSong(completion: (() -> Void)? = nil) {
        musicPlayerService.rewindPlayback { error in
            completion?()
        }
    }
    
}

extension PlayerViewModel: MusicPlayerServiceableDelegate  {
    func musicPlayerServiceable(error: MusicPlayerError) {
        print(error)
    }
}

extension PlayerViewModel: DataAccessProviderDelegate {
    func dataAccessProvider(_ dataAccessProvider: DataAccessProvider, error: DataAccessError) {
        print(error)
    }
}

