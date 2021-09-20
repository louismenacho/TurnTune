//
//  MusicPlayerError.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/29/21.
//

import Foundation

enum MusicPlayerError: Error {
    case initiate(error: Error)
    case startPlayback(error: Error)
    case pausePlayback(error: Error)
    case rewindPlayback(error: Error)
    
    case currentUserProfile(error: Error)
    case currentUserNotPremium
    case spotifyAppNotInstalled
    case authorizationFailed
    case renewSessionFailed
    case jsonFailed
    case unknown
}

extension MusicPlayerError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .initiate:
                return "Could not initiate"
            case .startPlayback:
                return "Could not start playback"
            case .pausePlayback:
                return "Could not pause playback"
            case .rewindPlayback:
                return "Could not rewind playback"
            case .currentUserProfile:
                return "Coult not get current user profile"
            case .currentUserNotPremium:
                return "Current user does not have a premium account"
            case .spotifyAppNotInstalled:
                return "Spotify app is not installed"
            case .authorizationFailed:
                return "Authorization Failed"
            case .renewSessionFailed:
                return "Could not renew session"
            case .jsonFailed:
                return "Failed to parse the returned JSON"
            case .unknown:
                return "An unknown error has occured"
        }
    }
}
