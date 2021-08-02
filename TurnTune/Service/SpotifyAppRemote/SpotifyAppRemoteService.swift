//
//  SpotifyAppRemoteService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/12/21.
//

import Foundation

protocol SpotifyAppRemoteServiceDelegate: AnyObject {
    func spotifyAppRemoteService(didAuthorize newSession: SPTSession)
    func spotifyAppRemoteService(didEstablishConnection appRemote: SPTAppRemote)
    func spotifyAppRemoteService(playerStateDidChange newPlayerState: SPTAppRemotePlayerState)
}

class SpotifyAppRemoteService: NSObject {
    
    weak var delegate: SpotifyAppRemoteServiceDelegate?
    
    private(set) var sessionManager = SpotifySessionManagerService()
    
    private(set) lazy var config: SPTConfiguration = {
        let config = SPTConfiguration(
            clientID: "695de2c68a184c69aaebdf6b2ed02260",
            redirectURL: URL(string: "TurnTune://spotify-login-callback")!
        )
        config.tokenSwapURL = URL(string: "https://turntune-spotify-token-swap.herokuapp.com/api/token")!
        config.tokenRefreshURL = URL(string: "https://turntune-spotify-token-swap.herokuapp.com/api/refresh_token")!
        return config
    }()
    
    private(set) lazy var appRemote: SPTAppRemote = {
        let appRemote =  SPTAppRemote(configuration: config, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()
    
    func initiate(play uri: String? = nil) {
        sessionManager.delegate = self
        sessionManager.initiateSession(with: uri)
    }
    
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
    
    func subscribe() {
        appRemote.playerAPI?.subscribe { id, error in
            if let error = error {
                print("appRemote playerState subscribe failed")
                print(self.errorMessage(for: error))
            }
        }
    }
    
    func play(trackUri: String, asRadio flag: Bool, completion: @escaping (Error?) -> Void) {
        appRemote.playerAPI?.play(trackUri, asRadio: flag) { _, error in
            completion(error)
        }
    }
    
    func errorMessage(for error: Error) -> String {
        guard
            let error = error as NSError?,
            let appRemoteErrorCode = SPTAppRemoteErrorCode(rawValue: error.code)
        else {
            return error.localizedDescription
        }
        
        switch appRemoteErrorCode {
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

extension SpotifyAppRemoteService: SpotifySessionManagerServiceDelegate {
    
    func spotifySessionManagerService(didAuthorize newSession: SPTSession) {
        setToken(newSession.accessToken)
        connect()
        delegate?.spotifyAppRemoteService(didAuthorize: newSession)
    }
}


extension SpotifyAppRemoteService: SPTAppRemoteDelegate {
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("SPTAppRemote appRemoteDidEstablishConnection")
        appRemote.playerAPI?.delegate = self
        delegate?.spotifyAppRemoteService(didEstablishConnection: appRemote)
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("appRemote didFailConnectionAttemptWithError")
        if let error = error {
            print(errorMessage(for: error))
        }
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("appRemote didDisconnectWithError")
        if let error = error {
            print(errorMessage(for: error))
        }
    }
}

extension SpotifyAppRemoteService: SPTAppRemotePlayerStateDelegate {
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        delegate?.spotifyAppRemoteService(playerStateDidChange: playerState)
//        debugPlayerState(playerState: playerState)
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
        print("\talbum name: \(playerState.track.album.name)\n")
    }
}
