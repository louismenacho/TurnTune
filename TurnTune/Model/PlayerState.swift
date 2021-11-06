//
//  PlayerState.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/5/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PlayerState: FirestoreDocument {
    
    @DocumentID var documentID: String? = "state"
    var dateAdded: Timestamp?
    
    var queueItem: QueueItem
    var position: Int
    var isPaused: Bool
    var didFinish: Bool
    var isPlayingQueue: Bool
    var hasHistory: Bool = false
    var isConnected: Bool = false
    
    init() {
        queueItem = QueueItem()
        position = 0
        isPaused = true
        didFinish = false
        isPlayingQueue = false
    }
    
    init(from spotifyPlayerState: SPTAppRemotePlayerState) {
        let song = Song(from: spotifyPlayerState.track)
        queueItem = QueueItem(song: song)
        position = spotifyPlayerState.playbackPosition
        isPaused = spotifyPlayerState.isPaused
        didFinish = spotifyPlayerState.isPaused && spotifyPlayerState.playbackPosition == 0
        isPlayingQueue = spotifyPlayerState.contextTitle.isEmpty
        isConnected = true
    }
    
    static func == (lhs: PlayerState, rhs: PlayerState) -> Bool {
        lhs.isPaused == rhs.isPaused && lhs.queueItem.song.spotifyURI == rhs.queueItem.song.spotifyURI && lhs.didFinish == rhs.didFinish
    }
    
}
