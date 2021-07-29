//
//  PlayerState.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/5/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PlayerState {
    var currentSong: Song
    var position: Int
    var isPaused: Bool
    var isRadio: Bool
    
    // MARK: - FirestoreDocument Protocol
    @DocumentID var documentID: String? = "state"
    
    init() {
        currentSong = Song()
        position = 0
        isPaused = true
        isRadio = true
    }
}

extension PlayerState: FirestoreDocument {}

extension PlayerState {
    init(from spotifyPlayerState: SPTAppRemotePlayerState) {
        currentSong = Song(from: spotifyPlayerState.track)
        position = spotifyPlayerState.playbackPosition
        isPaused = spotifyPlayerState.isPaused
        isRadio = spotifyPlayerState.contextURI.absoluteString.isEmpty ? false : true
    }
}
