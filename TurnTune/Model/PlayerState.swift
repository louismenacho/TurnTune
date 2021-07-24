//
//  PlayerState.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/5/21.
//

import Foundation

struct PlayerState {
    var currentSong: Song
    var position: Int
    var isPaused: Bool
    var isRadio: Bool
    
    // MARK: - FirestoreDocument Protocol
    var documentID: String?
    
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
        isRadio = spotifyPlayerState.contextTitle.isEmpty ? false : true
    }
}
