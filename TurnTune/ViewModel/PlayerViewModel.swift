//
//  PlayerViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/21/21.
//

import Foundation

class PlayerViewModel {
    
    private(set) var authService = FirebaseAuthService()
    private(set) var musicPlayerService: SpotifyMusicPlayerService?
    
    private(set) var playerStateDataAccess = PlayerStateDataAccessProvider()
    private(set) var queueDataAccess = QueueDataAccessProvider()
    
    var playerState = PlayerState()
    var queue = [QueueItem]()
    var history = [QueueItem]()
    
    init(musicPlayerService: SpotifyMusicPlayerService? = nil) {
        self.musicPlayerService = musicPlayerService
        self.playerStateDataAccess.delegate = self
        self.queueDataAccess.delegate = self
        
        musicPlayerService?.playerStateChangeListener { [self] newPlayerState in
            print("musicPlayerService listener called")
            if newPlayerState.didFinish {
                playNextSong()
            }
        }
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
    
    func addToQueue(_ song: Song, addedBy member: Member, memberPosition: Int, completion: (() -> Void)? = nil) {
        var item = QueueItem(song: song)
        let minPriority = queue.map { $0.priority }.min() ?? 0
        item.priority = songCount(for: member) * 10 + minPriority + memberPosition
        item.addedBy = member
        queueDataAccess.addItem(item) {
            completion?()
        }
    }
    
    func removeFromQueue(_ item: QueueItem, completion: (() -> Void)? = nil) {
        queueDataAccess.markDidPlay(item) {
            completion?()
        }
    }
    
    func removeQueueItems(for member: Member) {
        queue.forEach { queueItem in
            if queueItem.addedBy.userID == member.userID {
                queueDataAccess.removeItem(queueItem)
            }
        }
    }
    
    func songCount(for member: Member) -> Int {
        queue.filter({ $0.addedBy.userID == member.userID }).count
    }
    
    func removeAllListeners() {
        playerStateDataAccess.removeListener()
        queueDataAccess.removeListener()
    }
    
    // MARK: - Host Methods
    
    func updatePlayerState(_ playerState: PlayerState, completion: (() -> Void)? = nil) {
        playerStateDataAccess.updatePlayerState(playerState) {
            completion?()
        }
    }
    
    func play(_ items: [QueueItem]? = nil, position: Int = 0, completion: (() -> Void)? = nil ) {
        musicPlayerService?.startPlayback(songs: items?.compactMap { $0.song }, position: position) { [self] in
            if let items = items {
                print("playing \(items.compactMap { $0.song.name })")
                playerState.queueItem = items[0]
                playerState.isPaused = false
                updatePlayerState(playerState) {
                    completion?()
                }
            } else {
                print("resuming playback")
                playerState.isPaused = false
                updatePlayerState(playerState)  {
                    completion?()
                }
            }
        }
    }
    
    func playNextSong(completion: (() -> Void)? = nil) {
        guard let nextQueueItem = queue.first else {
            return
        }
        print("playing next song")
        play([nextQueueItem]) { [self] in
            print("played next song")
            removeFromQueue(nextQueueItem) {
                completion?()
            }
        }
    }
    
    func pause(completion: (() -> Void)? = nil) {
        musicPlayerService?.pausePlayback { [self] in
            playerState.isPaused = true
            updatePlayerState(playerState) {
                completion?()
            }
        }
    }
    
    func startQueue(completion: (() -> Void)? = nil) {
        guard let firstItem = queue.first else {
            return
        }
        musicPlayerService?.initiateSession(playing: firstItem.song) { [self] in
            playerState.queueItem = firstItem
            playerState.isPaused = false
            updatePlayerState(playerState) {
                completion?()
            }
            removeFromQueue(firstItem) {
                completion?()
            }
        }
    }
    
    func rewindSong(completion: (() -> Void)? = nil) {
        musicPlayerService?.rewindPlayback {
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

