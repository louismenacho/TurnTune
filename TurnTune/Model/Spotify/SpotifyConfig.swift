//
//  SpotifyConfig.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/12/21.
//

import Foundation

struct SpotifyConfig {
    var clientID: String
    var clientSecret: String
    var redirectURL: String
    var tokenSwapURL: String
    var tokenRefreshURL: String
    
    // MARK: - FirestoreDocument Protocol
    var documentID: String?
}

extension SpotifyConfig: FirestoreDocument {}
