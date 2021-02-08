//
//  SpotifyAccountsAPI.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/30/21.
//

import Foundation

enum SpotifyAccountsAPI {
    case apiToken
}

extension SpotifyAccountsAPI: APIEndpoint {
    
    var baseURL: URL {
        URL(string: "https://accounts.spotify.com")!
    }
    
    var authorization: APIAuthorization? {
        .basic(username: Constants.Spotify.clientID, password: Constants.Spotify.clientSecret)
    }
    
    var request: APIRequest {
        switch self {
        case .apiToken:
            return APIRequest(
                method: .post,
                path: "/api/token",
                headers: ["Content-Type": "application/x-www-form-urlencoded"],
                body: ["grant_type": "client_credentials"]
            )
        }
    }
}
