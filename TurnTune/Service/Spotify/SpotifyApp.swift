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
    private(set) static var fileConfig = FileConfig()
    
    private(set) var configuration: SPTConfiguration
    
    struct FileConfig: Decodable {
        var clientID: String!
        var clientSecret: String!
        var redirectURL: URL!
        var tokenSwapURL: URL!
        var tokenRefreshURL: URL!
    }
    
    private init() {
        configuration = SPTConfiguration(clientID: SpotifyApp.fileConfig.clientID, redirectURL: SpotifyApp.fileConfig.redirectURL)
        configuration.tokenSwapURL = SpotifyApp.fileConfig.tokenSwapURL
        configuration.tokenRefreshURL = SpotifyApp.fileConfig.tokenRefreshURL
        configuration.playURI = ""
    }
    
    static func configure() {
        let path = Bundle.main.path(forResource: "SpotifyService-Info", ofType: "plist")!
        let data = FileManager.default.contents(atPath: path)!
        fileConfig = try! PropertyListDecoder().decode(FileConfig.self, from: data)
        loadClientSecret()
    }
    
    private static func loadClientSecret() {
        Firestore.firestore().document("spotify/credentials").getDocument { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Could not load Spotify client secret")
                return
            }
            SpotifyApp.fileConfig.clientSecret = document.get("clientSecret") as? String
        }
    }
}
