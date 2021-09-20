//
//  MusicPlayerServiceable.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/14/21.
//

import Foundation

protocol MusicPlayerServiceableDelegate: AnyObject {
    func musicPlayerServiceable(error: MusicPlayerError)
}

protocol MusicPlayerServiceable {
    
    var delegate: MusicPlayerServiceableDelegate? { get set }
    
    func initiateSession(playing song: Song?, completion: (() -> Void)?)
    func startPlayback(songs: [Song]?, position: Int, completion: ((Error?) -> Void)?)
    func pausePlayback(completion: ((Error?) -> Void)?)
    func rewindPlayback(completion: ((Error?) -> Void)?)
    func playerStateChangeListener(completion: @escaping (PlayerState) -> Void)
}
