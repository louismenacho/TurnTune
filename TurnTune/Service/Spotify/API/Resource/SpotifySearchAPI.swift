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

extension SpotifySearchAPI: APIResource {
    
    var baseURL: URL {
        URL(string: "https://api.spotify.com/v1/search")!
    }
    
    var authorization: HTTPAuthorization {
        .bearer(token: SpotifyAPI.shared.searchToken)
    }
    
    var endpoint: APIEndpoint {
        switch self {
        case let .search(query, type, limit):
            return APIEndpoint(
                method: .get,
                params: [
                    "q": query,
                    "type": type,
                    "limit": "\(limit)"
                ]
            )
        }
    }
}
