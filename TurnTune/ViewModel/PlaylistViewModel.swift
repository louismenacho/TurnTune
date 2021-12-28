//
//  PlaylistViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/25/21.
//

import Foundation

class PlaylistViewModel: NSObject {

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
}

extension PlaylistViewModel: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        
    }
}
