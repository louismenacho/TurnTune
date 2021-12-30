//
//  PlaylistViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/25/21.
//

import Foundation

class PlaylistViewModel: NSObject {
    
    var session: Session
    var sessionRepository: FirestoreRepository<Session>
    
    var playlist: [Song]
    var playlistRepository: FirestoreRepository<Song>
    
    var spotifySessionManager: SPTSessionManager?
    private var spotifyRenewSessionCompletion: ((Result<SPTSession, Error>) -> Void)?
    
    init(_ session: Session, _ spotifySessionManager: SPTSessionManager?) {
        self.session = session
        self.sessionRepository = FirestoreRepository<Session>(collectionPath: "sessions")
        
        self.playlist = [Song]()
        self.playlistRepository = FirestoreRepository<Song>(collectionPath: "sessions/"+session.id+"/playlist")
        
        self.spotifySessionManager = spotifySessionManager
        super.init()
        self.spotifySessionManager?.delegate = self
    }
    
    func sessionChangeListener(completion: @escaping (Result<Session, RepositoryError>) -> Void) {
        sessionRepository.addListener(id: session.id) { result in
            completion( result.flatMap { session in
                self.session = session
                return .success(session)
            })
        }
    }
    
    func updateSession(completion: @escaping (Result<Void, RepositoryError>) -> Void) {
        sessionRepository.update(session) { error in
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
            completion( result.flatMap { songs in
                self.playlist = songs
                return .success(())
            })
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
    
    func renewSpotifyToken(completion: @escaping (Result<Void, Error>) -> Void) {
        spotifySessionManager?.renewSession()
        spotifyRenewSessionCompletion = { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let spotifySession):
                self.session.spotifyToken = spotifySession.accessToken
                completion(.success(()))
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
