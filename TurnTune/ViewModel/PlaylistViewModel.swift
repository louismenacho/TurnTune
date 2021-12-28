//
//  PlaylistViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/25/21.
//

import Foundation

class PlaylistViewModel: NSObject {

    var session: Session
    var spotifySessionManager: SPTSessionManager
    
    init(_ session: Session, _ spotifySessionManager: SPTSessionManager) {
        self.session = session
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
