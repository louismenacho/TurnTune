//
//  SpotifyAppRemote.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/28/21.
//

import Foundation

protocol SpotifyAppRemoteDelegate: class {
    func spotifyAppRemote(spotifyAppRemote: SpotifyAppRemote, trackDidChange track: SPTAppRemoteTrack)
}

class SpotifyAppRemote: NSObject {
    
    weak var delegate: SpotifyAppRemoteDelegate?
    
    private(set) static var shared = SpotifyAppRemote()
    
    private let appRemote: SPTAppRemote
    private var playerState: SPTAppRemotePlayerState?
    
    var isConnected: Bool { appRemote.isConnected }
    var hasAccessToken: Bool { appRemote.connectionParameters.accessToken != nil }
    
    private override init() {
        appRemote = SPTAppRemote(configuration: SpotifyApp.shared.configuration, logLevel: .debug)
        super.init()
        appRemote.delegate = self
    }
    
    func setAccessToken(_ token: String) {
        appRemote.connectionParameters.accessToken = token
    }
    
    func connect() {
        if !appRemote.isConnected {
            appRemote.connect()
        }
    }
    
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
    
    func connectIfNeeded() {
        SPTAppRemote.checkIfSpotifyAppIsActive { [self] isActive in
            if isActive {
                connect()
            } else {
                SpotifySessionManager.shared.initiateSession()
            }
        }
    }
    
    func configurePlayerAPI() {
        guard let player = appRemote.playerAPI else {
            print("appRemote.playerAPI is nil")
            return
        }
        if player.delegate == nil {
            player.delegate = self
            player.subscribe()
            player.setRepeatMode(.off)
        }
    }
    
    func handleAppRemoteError(_ error: Error?) -> SPTAppRemoteErrorCode? {
        guard
            let error = error as NSError?
        else {
            print("No error")
            return nil
        }
        
        let appRemoteErrorCode = SPTAppRemoteErrorCode(rawValue: error.code)
        
        switch appRemoteErrorCode {
        case .backgroundWakeupFailedError:
            print("backgroundWakeupFailedError")
        case .connectionAttemptFailedError:
            print("connectionAttemptFailedError")
        case .connectionTerminatedError:
            print("connectionTerminatedError")
        case .invalidArgumentsError:
            print("invalidArgumentsError")
        case .requestFailedError:
            print("requestFailedError")
        case .unknownError:
            print("unknownError")
        default:
            print("Could not resolve appRemoteErrorCode")
        }
        
        return appRemoteErrorCode
    }
}

extension SpotifyAppRemote: SPTAppRemoteDelegate {
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("SPTAppRemote appRemoteDidEstablishConnection")
        configurePlayerAPI()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("appRemote didFailConnectionAttemptWithError")
        _ = handleAppRemoteError(error)
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("appRemote didDisconnectWithError")
        _  = handleAppRemoteError(error)
    }
}

extension SpotifyAppRemote: SPTAppRemotePlayerStateDelegate {
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        if self.playerState?.track.uri != playerState.track.uri {
            self.delegate?.spotifyAppRemote(spotifyAppRemote: self, trackDidChange: playerState.track)
            print("spotifyAppRemote trackDidChange")
        }
        self.playerState = playerState
    }
}
