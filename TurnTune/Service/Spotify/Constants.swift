//
//  Constants.swift
//  TurnTune
//
//  Created by Louis Menacho on 3/15/21.
//

import Foundation
import FirebaseFirestore

struct Spotify {
    
    struct APIToken {
        static var searchToken: String = ""
        static var accessToken: String = ""
    }
    
    struct Credentials {
        static var clientID: String = ""
        static var clientSecret: String = ""
        static var redirectURL: URL!
        static var tokenSwapURL: URL!
        static var tokenRefreshURL: URL!
    }
    
    static func loadConfigFile() {
        struct SpotifyConfig: Decodable {
            var clientID: String
            var redirectURL: URL
            var tokenSwapURL: URL
            var tokenRefreshURL: URL
        }
        let path = Bundle.main.path(forResource: "SpotifyService-Info", ofType: "plist")!
        let data = FileManager.default.contents(atPath: path)!
        let config = try! PropertyListDecoder().decode(SpotifyConfig.self, from: data)
        Credentials.clientID = config.clientID
        Credentials.redirectURL = config.redirectURL
        Credentials.tokenSwapURL = config.tokenSwapURL
        Credentials.tokenRefreshURL = config.tokenRefreshURL
    }
    
    static func loadClientSecret() {
        Firestore.firestore().document("spotify/credentials").getDocument { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Could not load Spotify client secret")
                return
            }
            Credentials.clientSecret = document.get("clientSecret") as! String
        }
    }
}
