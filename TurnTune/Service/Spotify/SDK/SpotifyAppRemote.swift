//
//  SpotifyAppRemote.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/28/21.
//

import Foundation

class SpotifyAppRemote: NSObject {
    
    private(set) static var shared = SpotifyAppRemote()
    
    private let appRemote: SPTAppRemote
    
    var isConnected: Bool { appRemote.isConnected }
    var hasAccessToken: Bool { appRemote.connectionParameters.accessToken != nil }
    var playerAPI: SPTAppRemotePlayerAPI? { appRemote.playerAPI }
    
    private override init() {
        appRemote = SPTAppRemote(configuration: SpotifyApp.shared.configuration, logLevel: .debug)
        super.init()
        appRemote.delegate = self
    }
    
    func setAccessToken(_ token: String) {
        appRemote.connectionParameters.accessToken = token
    }
    
    func connect() {
        appRemote.connect()
    }
    
    func disconnect() {
        appRemote.disconnect()
    }
    
    func connectIfNeeded() {
        SPTAppRemote.checkIfSpotifyAppIsActive { [self] isActive in
            if isActive {
                isConnected ? () : connect()
            } else {
                SpotifySessionManager.shared.initiateSession()
            }
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

//Fix issue with double pressing pause, perhaps automatic retry with retry limit
extension SpotifyAppRemote: SPTAppRemoteDelegate {
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("SPTAppRemote appRemoteDidEstablishConnection")
        SpotifyPlayer.shared.configure()
//        SpotifyPlayer.shared.isPendingPlayback() ? SpotifyPlayer.shared.retryPlayback() : ()
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
