//
//  SpotifyPlayerAPI.swift
//  TurnTune
//
//  Created by Louis Menacho on 3/18/21.
//

import Foundation

enum SpotifyPlayerAPI: APIEndpoint {
    case currentlyPlayingTrack
    case playTrack(uris: [String])
    case pausePlayback
    case queueTrack(uri: String)
    
    var request: APIRequest {
        var apiRequest = APIRequest(
            baseURL: "https://api.spotify.com/v1/me/player"
        )
        
        switch self {
        case .currentlyPlayingTrack:
            apiRequest.method = .get
            apiRequest.path =   "/currently-playing"
            
        case .playTrack(let uris):
            apiRequest.method = .put
            apiRequest.path =   "/play"
            apiRequest.header = ["Content-Type": "application/json"]
            apiRequest.body =   ["uris": uris]
            
        case .pausePlayback:
            apiRequest.method = .put
            apiRequest.path =   "/pause"
            
        case .queueTrack(let uri):
            apiRequest.method = .post
            apiRequest.path =   "/queue"
            apiRequest.header = ["Content-Type": "application/json"]
            apiRequest.body =   ["uri": uri]
        }
        
        return apiRequest
    }
    
}
