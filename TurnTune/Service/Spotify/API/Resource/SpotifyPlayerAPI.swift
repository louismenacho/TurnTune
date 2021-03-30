//
//  SpotifyPlayerAPI.swift
//  TurnTune
//
//  Created by Louis Menacho on 3/18/21.
//

import Foundation

enum SpotifyPlayerAPI {
    case currentlyPlayingTrack
    case playTrack(uris: [String])
    case pausePlayback
    case queueTrack(uri: String)
}

extension SpotifyPlayerAPI: APIResource {
    
    var baseURL: URL {
        URL(string: "https://api.spotify.com/v1/me/player")!
    }
    
    var authorization: HTTPAuthorization {
        .bearer(token: Spotify.APIToken.accessToken)
    }
    
    var endpoint: APIEndpoint {
        switch self {
        case .currentlyPlayingTrack:
            return APIEndpoint(
                method: .get,
                path: "/currently-playing"
            )
        case .playTrack(let uris):
            return APIEndpoint(
                method: .put,
                path: "/play",
                body: [
                    "uris": uris
                ]
            )
        case .pausePlayback:
            return APIEndpoint(
                method: .put,
                path: "/pause"
            )
        case .queueTrack(let uri):
            return APIEndpoint(
                method: .post,
                path: "/queue",
                body: [
                    "uri": uri
                ]
            )
        }
    }
}
