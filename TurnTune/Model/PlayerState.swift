//
//  PlayerState.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/5/21.
//

import Foundation

struct PlayerState: Codable {
    var isPaused: Bool = true
    var playbackPosition: Int = 0
    var playingSong: Song?
    
    init() {}
    
    init(spotifyPlayerState: SPTAppRemotePlayerState) {
        isPaused = spotifyPlayerState.isPaused
        playbackPosition = spotifyPlayerState.playbackPosition
        playingSong = Song(spotifyTrack: spotifyPlayerState.track)
    }
}
