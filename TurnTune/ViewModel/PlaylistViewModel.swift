//
//  PlaylistViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/25/21.
//

import Foundation

class PlaylistViewModel: NSObject {
    
    var playlist = [Song]()

    var session: Session
    var playlistRepository: FirestoreRepository<Song>
    var spotifySessionManager: SPTSessionManager
    
    init(_ session: Session, _ spotifySessionManager: SPTSessionManager) {
        self.session = session
        self.playlistRepository = FirestoreRepository<Song>(collectionPath: "sessions/"+session.code+"/playlist")
        self.spotifySessionManager = spotifySessionManager
        super.init()
        self.spotifySessionManager.delegate = self
    }
    
    func addSong(_ song: Song, completion: @escaping (Result<Void, RepositoryError>) -> Void) {
        playlistRepository.create(song) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func playlistChangeListener(completion: @escaping (Result<Void, RepositoryError>) -> Void) {
        let query = playlistRepository.collectionReference.order(by: "dateAdded", descending: true)
        playlistRepository.addListener(query) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(songs):
                self.playlist = songs
                completion(.success(()))
            }
        }
    }
}

extension PlaylistViewModel: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        
    }
}
