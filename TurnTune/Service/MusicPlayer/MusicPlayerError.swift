//
//  MusicPlayerError.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/29/21.
//

import Foundation

enum MusicPlayerError: Error {
    case initiate(error: Error?)
    case startPlayback(error: HTTPError)
    case pausePlayback(error: HTTPError)
    case rewindPlayback(error: HTTPError)
    case currentUserProfile(error: HTTPError)
    case getPlayerState(error: HTTPError)
    case currentUserIsNotPremium
    case spotifyAppNotInstalled
    
    // Spotify Errors
    case spotify(code: SPTErrorCode)
    case spotifyAppRemote(code: SPTAppRemoteErrorCode)
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
            case .currentUserIsNotPremium:
                return "Current user does not have a premium account"
            case .getPlayerState:
                return "Could not get player state"
            case .spotifyAppNotInstalled:
                return "Spotify app is not installed"
            case .spotify(let code):
                switch code {
                    case .authorizationFailed:
                        return "authorization failed"
                    case .renewSessionFailed:
                        return ""
                    case .jsonFailed:
                        return ""
                    case .unknown:
                        return ""
                    default:
                        return ""
                }
            case .spotifyAppRemote(let code):
                switch code {
                    case .backgroundWakeupFailedError:
                        return "backgroundWakeupFailedError"
                    case .connectionAttemptFailedError:
                        return "connectionAttemptFailedError"
                    case .connectionTerminatedError:
                        return "connectionTerminatedError"
                    case .invalidArgumentsError:
                        return "invalidArgumentsError"
                    case .requestFailedError:
                        return "requestFailedError"
                    case .unknownError:
                        return "unknownError"
                    default:
                        return "Could not resolve appRemoteErrorCode"
                }
        }
    }
}
