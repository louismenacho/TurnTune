//
//  SearcherViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/28/21.
//

import Foundation

class SearcherViewModel {
    
    private(set) var musicBrowserService: MusicBrowserServiceable
    
    private(set) var searchResult = [Song]()
    
    init(musicBrowserService: MusicBrowserServiceable) {
        self.musicBrowserService = musicBrowserService
    }
    
    func search(query: String, completion: @escaping () -> Void) {
        musicBrowserService.searchSong(query: query) { [self] (result: Result<[Song], Error>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(songSearchResult):
                searchResult = songSearchResult
                completion()
            }
        }
    }
}
