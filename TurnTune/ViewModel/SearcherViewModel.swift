//
//  SearcherViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/28/21.
//

import Foundation

class SearcherViewModel {
    
    private(set) var roomViewModel: RoomViewModel
    
    private(set) var searchResult = [Song]()
    
    lazy var authentication = roomViewModel.authentication
    lazy var roomManager = roomViewModel.roomManager
    lazy var queue = roomViewModel.queue
    lazy var memberList = roomViewModel.memberList
    
    init(roomViewModel: RoomViewModel) {
        self.roomViewModel = roomViewModel
    }
    
    func search(query: String, completion: @escaping () -> Void) {
        roomViewModel.musicService.searchSong(query: query) { [self] (result: Result<[Song], Error>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(songSearchResult):
                searchResult = songSearchResult
                completion()
            }
        }
    }
    
    func queueSong(_ song: Song) {
        var newSong = song
        newSong.orderGroup = queue.filter({ $0.addedBy?.id == authentication.currentUser()?.uid }).count
        newSong.addedBy = memberList.first { $0.id == authentication.currentUser()?.uid }
        roomManager.queueSong(newSong) { error in
            if let error = error {
                print(error)
            }
        }
    }
}
