//
//  SpotifyService.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/4/21.
//

import Foundation
import Firebase

protocol SpotifyServiceDelegate: class {
    func spotifyService(spotifyService: SpotifyService, playerDidChangeTrack track: SPTAppRemoteTrack)
    func spotifyService(spotifyService: SpotifyService, playerDidFinishTrack track: SPTAppRemoteTrack)
}

class SpotifyService: NSObject {
    
    weak var delegate: SpotifyServiceDelegate?
    
    private(set) var sessionManager: SPTSessionManager
    private(set) var appRemote: SPTAppRemote
    private(set) var playerState: SPTAppRemotePlayerState?
    
    private var playerAPI: SPTAppRemotePlayerAPI? { appRemote.playerAPI }
    private var pendingPlaybackURI: String?
    
    // Silent track to keep app awake for 4 minutes
    private var silentTrackURI: String = "spotify:track:7p5bQJB4XsZJEEn6Tb7EaL"
    
    
    override init() {
        let configuration = SpotifyApp.shared.configuration
        configuration.playURI = silentTrackURI
        appRemote = SPTAppRemote(configuration: configuration, logLevel: .none)
        sessionManager = SPTSessionManager(configuration: configuration, delegate: nil)
        super.init()
    }
    
    func initiateSession() {
        appRemote.delegate = self
        sessionManager.delegate = self
        sessionManager.initiateSession(with: .appRemoteControl, options: .default)
    }
    
    func playTrack(uri: String, completion: (() -> Void)? = nil) {
        reconnectIfNeeded() { willReconnect in
            if willReconnect {
                self.pendingPlaybackURI = uri
            } else {
                self.appRemote.playerAPI?.play(uri, asRadio: false) { _, error in
                    if let error = error { print(error.localizedDescription) }
                    completion?()
                }
            }
        }
    }
    
    func pausePlayback( completion: (() -> Void)? = nil) {
        reconnectIfNeeded() { willReconnect in
            if willReconnect {
                print("willReconnect")
            } else {
                print("willNotReconnect")
                self.appRemote.playerAPI?.pause { _, error in
                    if let error = error { print(error.localizedDescription) }
                    completion?()
                }
            }
        }
    }
    
    func reconnectIfNeeded(willReconnect: @escaping (Bool) -> Void) {
        guard let session = sessionManager.session else {
            print("No seession found when attempting to reconnect")
            return
        }
        
        if session.isExpired {
            sessionManager.renewSession()
            willReconnect(true)
            return
        }
        
        if !appRemote.isConnected {
            appRemote.connect()
            willReconnect(true)
            return
        }
        
        willReconnect(false)
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



extension SpotifyService: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("SPTSession didInitiate")
        appRemote.connectionParameters.accessToken = session.accessToken
        DispatchQueue.main.async {
            self.appRemote.connect()
        }
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("SPTSession didRenew")
        appRemote.connectionParameters.accessToken = session.accessToken
        DispatchQueue.main.async {
            self.appRemote.connect()
        }
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("SPTSession didFailWith")
        print(error.localizedDescription)
    }
}


extension SpotifyService: SPTAppRemoteDelegate {

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("SPTAppRemote appRemoteDidEstablishConnection")
        playerAPI?.delegate = self
        playerAPI?.subscribe()
        playerAPI?.setRepeatMode(.off)
        if let pendingPlaybackURI = pendingPlaybackURI {
            playTrack(uri: pendingPlaybackURI)
            self.pendingPlaybackURI = nil
        }
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("SPTAppRemote didFailConnectionAttemptWithError")
        let errorCode = handleAppRemoteError(error)
        switch errorCode {
        case .connectionTerminatedError:
            DispatchQueue.main.async {
                self.appRemote.connect()
            }
        default:
            break
        }
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("SPTAppRemote didDisconnectWithError")
        let errorCode = handleAppRemoteError(error)
        switch errorCode {
        case .backgroundWakeupFailedError:
            if pendingPlaybackURI != nil {
                self.sessionManager.initiateSession(with: .appRemoteControl, options: .default)
            }
        default:
            break
        }
    }
}

extension SpotifyService: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        
        if self.playerState?.track.uri != playerState.track.uri {
            self.delegate?.spotifyService(spotifyService: self, playerDidChangeTrack: playerState.track)
        }
        
        if !playerState.isPaused && playerState.contextURI.absoluteString.contains("station") {
            pausePlayback() {
                print("track ended")
                self.delegate?.spotifyService(spotifyService: self, playerDidFinishTrack: playerState.track)
            }
        }
        
        self.playerState = playerState
    }
}
