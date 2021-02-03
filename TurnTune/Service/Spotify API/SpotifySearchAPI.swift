//
//  SpotifySearchAPI.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/2/21.
//

import Foundation

enum SpotifySearchAPI {
    case search(query: String, type: String, limit: Int)
}

extension SpotifySearchAPI: APIEndpoint {
    
    var baseURL: URL {
        URL(string: "https://api.spotify.com/v1")!
    }
    
    var authorization: APIAuthorization? {
        .bearer(token: Constants.Spotify.accessToken)
    }
    
    var request: APIRequest {
        switch self {
        case let .search(query, type, limit):
            return APIRequest(
                method: .get,
                path: "/search",
                query: [
                    "q": query,
                    "type": type,
                    "limit": "\(limit)"
                ]
            )
        }

    }
}
