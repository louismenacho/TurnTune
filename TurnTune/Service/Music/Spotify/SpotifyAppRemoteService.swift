//
//  SpotifyAppRemoteService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/12/21.
//

import Foundation

protocol SpotifyAppRemoteServiceDelegate: AnyObject {
    func spotifyAppRemoteService(didEstablishConnection appRemote: SPTAppRemote)
    func spotifyAppRemoteService(playerStateDidChange playerState: SPTAppRemotePlayerState)
}

class SpotifyAppRemoteService: NSObject {
    
    weak var delegate: SpotifyAppRemoteServiceDelegate?
    
    private(set) lazy var appRemote: SPTAppRemote = {
        let config = SPTConfiguration(
            clientID: "695de2c68a184c69aaebdf6b2ed02260",
            redirectURL: URL(string: "TurnTune://spotify-login-callback")!
        )
        config.tokenSwapURL = URL(string: "https://turntune-spotify-token-swap.herokuapp.com/api/token")!
        config.tokenRefreshURL = URL(string: "https://turntune-spotify-token-swap.herokuapp.com/api/refresh_token")!
        config.playURI = ""
        let appRemote =  SPTAppRemote(configuration: config, logLevel: .none)
        appRemote.delegate = self
        return appRemote
    }()
    
    func setToken(_ accessToken: String) {
        appRemote.connectionParameters.accessToken = accessToken
    }
    
    func connect() {
        if !appRemote.isConnected && appRemote.connectionParameters.accessToken != nil {
            appRemote.connect()
        }
    }
    
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
    
    func play(trackUri: String, asRadio flag: Bool, completion: @escaping (Error?) -> Void) {
        appRemote.playerAPI?.play(trackUri, asRadio: flag) { _, error in
            completion(error)
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

extension SpotifyAppRemoteService: SPTAppRemoteDelegate {
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("SPTAppRemote appRemoteDidEstablishConnection")
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe { id, error in
            if let error = error {
                _ = self.handleAppRemoteError(error)
                print("appRemote playerState subscribe failed: \(error)")
            }
        }
        delegate?.spotifyAppRemoteService(didEstablishConnection: appRemote)
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("appRemote didFailConnectionAttemptWithError")
        _ = handleAppRemoteError(error)
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("appRemote didDisconnectWithError")
        _ = handleAppRemoteError(error)
    }
}

extension SpotifyAppRemoteService: SPTAppRemotePlayerStateDelegate {
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("playerStateDidChange")
        debugPlayerState(playerState: playerState)
        delegate?.spotifyAppRemoteService(playerStateDidChange: playerState)
    }
    
    func debugPlayerState(playerState: SPTAppRemotePlayerState) {
        print("\tcontextTitle: \(playerState.contextTitle)")
        print("\tcontextURI: \(playerState.contextURI)")
        print("\tisPaused: \(playerState.isPaused)")
        print("\tplaybackPosition: \(playerState.playbackPosition)")
        print("\tplaybackSpeed: \(playerState.playbackSpeed)")
        print("\turi: \(playerState.track.uri)")
        print("\ttrack name: \(playerState.track.name)")
        print("\tartist name: \(playerState.track.artist.name)")
        print("\talbum name: \(playerState.track.album.name)")
    }
}
