//
//  MusicPlayerServiceable.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/14/21.
//

import Foundation

protocol MusicPlayerServiceableDelegate: AnyObject {
//    func musicPlayerServiceable(playbackDidStart playerState: PlayerState)
//    func musicPlayerServiceable(playbackDidPause playerState: PlayerState)
//    func musicPlayerServiceable(playbackDidFinish playerState: PlayerState)
//    func musicPlayerServiceable(playbackDidChange playerState: PlayerState)
    func musicPlayerServiceable(error: MusicPlayerServiceableError)
}

protocol MusicPlayerServiceable {
    
    var delegate: MusicPlayerServiceableDelegate? { get set }
    
    func initiate(completion: (() -> Void)?)
    func startPlayback(songs: [Song]?, position: Int, completion: (() -> Void)?)
    func pausePlayback(completion: (() -> Void)?)
    func rewindPlayback(completion: (() -> Void)?)
    func playerStateChangeListener(completion: @escaping (PlayerState) -> Void)
}
