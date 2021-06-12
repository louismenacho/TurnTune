//
//  MusicService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/3/21.
//

import Foundation
import FirebaseFirestoreSwift

protocol MusicService {
    associatedtype Song
    
    func play(song: Song, completion: @escaping (Error?) -> Void)
    func pause(completion: @escaping (Error?) -> Void)
    func playingSongDidChange(completion: @escaping (Result<Song, Error>) -> Void)
    func searchSong(query: String, completion: @escaping (Result<[Song], Error>) -> Void)
}
