//
//  MusicServiceable.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/3/21.
//

import Foundation

protocol MusicServiceableDelegate: AnyObject {
    func musicServiceable(musicServiceable: MusicServiceable, didInitiateWith playerState: PlayerState)
    func musicServiceable(musicServiceable: MusicServiceable, playingSongDidChange playerState: PlayerState)
    func musicServiceable(musicServiceable: MusicServiceable, playingSongDidFinish playerState: PlayerState)
}

protocol MusicServiceable {
    var delegate: MusicServiceableDelegate? { get set }
    
    func startPlayback(songs: [Song]?, position: Int, completion: @escaping (Error?) -> Void)
    func pausePlayback(completion: @escaping (Error?) -> Void)
    func searchSong(query: String, completion: @escaping (Result<[Song], Error>) -> Void)
    func getSongRecommendations(from recentSongs: [Song], completion: @escaping (Result<[Song], Error>) -> Void)
}
