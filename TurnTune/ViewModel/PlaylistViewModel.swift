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
    var spotifySessionManager: SPTSessionManager?
    private var spotifyRenewSessionCompletion: ((Result<SPTSession, Error>) -> Void)?
    
    init(_ session: Session, _ spotifySessionManager: SPTSessionManager?) {
        self.session = session
        self.playlistRepository = FirestoreRepository<Song>(collectionPath: "sessions/"+session.id+"/playlist")
        self.spotifySessionManager = spotifySessionManager
        super.init()
        if let spotifySessionManager = spotifySessionManager {
            spotifySessionManager.delegate = self
        }
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
        let query = playlistRepository.collectionReference.order(by: "dateAdded")
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
    
    func renewSpotifyToken(completion: @escaping (Result<String, Error>) -> Void) {
        self.spotifySessionManager?.renewSession()
        self.spotifyRenewSessionCompletion = { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let session):
                completion(.success(session.accessToken))
            }
        }
    }
}

extension PlaylistViewModel: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("sessionManager did renew session")
        spotifyRenewSessionCompletion?(.success(session))
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        
    }
}
