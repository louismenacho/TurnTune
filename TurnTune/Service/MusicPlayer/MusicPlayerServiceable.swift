//
//  MusicPlayerServiceable.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/14/21.
//

import Foundation

protocol MusicPlayerServiceableDelegate: AnyObject {
    func musicPlayerServiceable(playbackDidStart playerState: PlayerState)
    func musicPlayerServiceable(playbackDidPause playerState: PlayerState)
    func musicPlayerServiceable(playbackDidFinish playerState: PlayerState)
    func musicPlayerServiceable(playbackDidChange playerState: PlayerState)
}

protocol MusicPlayerServiceable {
    
    var delegate: MusicPlayerServiceableDelegate? { get set }
    
    func initiate(delegate: MusicPlayerServiceableDelegate?)
    func startPlayback(songs: [Song]?, position: Int, completion: @escaping (Error?) -> Void)
    func pausePlayback(completion: @escaping (Error?) -> Void)
}
