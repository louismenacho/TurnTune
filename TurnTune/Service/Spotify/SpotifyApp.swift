//
//  SpotifyApp.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/4/21.
//

import Foundation
import Firebase

class SpotifyApp: NSObject {
    
    private static var configuration: SPTConfiguration?
        
    static func configure() {
        
        struct SPTCredentials: Codable {
            var clientID: String
            var redirectURL: String
            var tokenSwapURL: String
            var tokenRefreshURL: String
            
            enum CodingKeys: String, CodingKey {
                case clientID = "CLIENT_ID"
                case redirectURL = "REDIRECT_URL"
                case tokenSwapURL = "TOKEN_SWAP_URL"
                case tokenRefreshURL = "TOKEN_REFRESH_URL"
            }
        }
        
        guard
            let path = Bundle.main.path(forResource: "SpotifyService-Info", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path),
            let credentials = try? PropertyListDecoder().decode(SPTCredentials.self, from: xml)
        else {
            print("Could not configure SpotifyApp")
            return
        }
        
        let configuration = SPTConfiguration(clientID: credentials.clientID, redirectURL: URL(string:credentials.redirectURL)!)
        configuration.tokenSwapURL = URL(string: credentials.tokenSwapURL)
        configuration.tokenRefreshURL = URL(string: credentials.tokenRefreshURL)
        configuration.playURI = ""
        self.configuration = configuration
    }
}
