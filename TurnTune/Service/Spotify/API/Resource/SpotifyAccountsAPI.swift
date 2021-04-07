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
        .basic(username: SpotifyApp.fileConfig.clientID, password: SpotifyApp.fileConfig.clientSecret)
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
