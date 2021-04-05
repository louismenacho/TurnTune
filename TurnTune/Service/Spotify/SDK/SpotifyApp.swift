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
    
    private(set) var fileConfig = FileConfig()
    private(set) var configuration: SPTConfiguration
    
    struct FileConfig: Decodable {
        var clientID: String!
        var clientSecret: String!
        var redirectURL: URL!
        var tokenSwapURL: URL!
        var tokenRefreshURL: URL!
    }
    
    private init() {
        configuration = SPTConfiguration(clientID: fileConfig.clientID, redirectURL: fileConfig.redirectURL)
        configuration.tokenSwapURL = fileConfig.tokenSwapURL
        configuration.tokenRefreshURL = fileConfig.tokenRefreshURL
    }
    
    static func configure() {
        let path = Bundle.main.path(forResource: "SpotifyService-Info", ofType: "plist")!
        let data = FileManager.default.contents(atPath: path)!
        shared.fileConfig = try! PropertyListDecoder().decode(FileConfig.self, from: data)
        loadClientSecret()
    }
    
    private static func loadClientSecret() {
        Firestore.firestore().document("spotify/credentials").getDocument { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Could not load Spotify client secret")
                return
            }
            shared.fileConfig.clientSecret = document.get("clientSecret") as? String
        }
    }
}
