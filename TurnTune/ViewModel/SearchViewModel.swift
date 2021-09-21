//
//  SearchViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/28/21.
//

import Foundation

class SearchViewModel {
    
    private(set) var musicBrowserService: SpotifyMusicBrowserService
    
    var searchResult = [SearchResultItem]()
        
    init(musicBrowserService: SpotifyMusicBrowserService) {
        self.musicBrowserService = musicBrowserService
    }
    
    func search(query: String, completion: @escaping () -> Void) {
        musicBrowserService.searchSong(query: query) { [self] songSearchResult in
            searchResult = songSearchResult.map { SearchResultItem(song: $0) }
            completion()
        }
    }
}

struct SearchResultItem {
    var song: Song = Song()
    var isAdded: Bool = false
}
