//
//  MusicBrowserServiceable.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/18/21.
//

import Foundation

protocol MusicBrowserServiceable {
    func searchSong(query: String, completion: @escaping (Result<[Song], Error>) -> Void)
    func getRecentlyPlayedTracks(completion: @escaping (Result<[Song], Error>) -> Void) 
    func getSongRecommendations(from recentSongs: [Song], completion: @escaping (Result<[Song], Error>) -> Void)
}
