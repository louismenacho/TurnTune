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

extension SpotifyAccountsAPI: APIResource {
    
    var baseURL: URL {
        return URL(string: "https://accounts.spotify.com")!
    }
    
    var authorization: HTTPAuthorization {
        .basic(username: Spotify.Credentials.clientID, password: Spotify.Credentials.clientSecret)
    }
    
    var endpoint: APIEndpoint {
        switch self {
        case .apiToken:
            return APIEndpoint(
                method: .post,
                path: "/api/token",
                headers: ["Content-Type": "application/x-www-form-urlencoded"],
                body: ["grant_type": "client_credentials"]
            )
        }
    }
}
