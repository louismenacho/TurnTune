//
//  SpotifyApp.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/19/21.
//

import Foundation
import FirebaseFirestore

class SpotifyApp {
    
    private(set) static var shared = SpotifyApp()
    
    private(set) var configuration: SPTConfiguration
    
    private init() {
        configuration = SPTConfiguration(clientID: Spotify.Credentials.clientID, redirectURL: Spotify.Credentials.redirectURL)
        configuration.tokenSwapURL = Spotify.Credentials.tokenSwapURL
        configuration.tokenRefreshURL = Spotify.Credentials.tokenRefreshURL
    }
}
