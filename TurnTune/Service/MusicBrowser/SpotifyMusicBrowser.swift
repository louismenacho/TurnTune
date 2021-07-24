//
//  SpotifyMusicBrowser.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/18/21.
//

import Foundation

class SpotifyMusicBrowser: MusicBrowserServiceable {
    
    private var webService = SpotifyWebService()
    
    func searchSong(query: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        webService.search(query: query) { (result: Result<SearchResponse, Error>) in
            let songSearchResult = Result {
                try result.get().tracks.items.map { trackItem in
                    Song(from: trackItem)
                }
            }
            completion(songSearchResult)
        }
    }
    
    func getRecentlyPlayedTracks(completion: @escaping (Result<[Song], Error>) -> Void) {
        webService.recentlyPlayedTracks { (result: Result<RecentlyPlayedResponse, Error>) in
            let recentlyPlayedTracksResult = Result {
                try result.get().items.map { item in
                    Song(from: item)
                }
            }
            completion(recentlyPlayedTracksResult)
        }
    }
    
    func getSongRecommendations(from recentSongs: [Song], completion: @escaping (Result<[Song], Error>) -> Void) {
        webService.recommendations(limit: 20, seedTrackIDs: recentSongs.compactMap { $0.spotifyID }) { (result: Result<RecommendationsResponse, Error>) in
            let recommendationsResult = Result {
                try result.get().tracks.map { track in
                    Song(from: track)
                }
            }
            completion(recommendationsResult)
        }
    }
    
}
