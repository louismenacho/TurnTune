//
//  SpotifySessionManagerService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/26/21.
//

import Foundation

protocol SpotifySessionManagerServiceDelegate: AnyObject {
    func spotifySessionManagerService(didInitiate session: SPTSession)
    func spotifySessionManagerService(didRenew session: SPTSession)
}


class SpotifySessionManagerService: NSObject {
    
    weak var delegate: SpotifySessionManagerServiceDelegate?
    
    private(set) lazy var sessionManager: SPTSessionManager = {
        let config = SPTConfiguration(
            clientID: "695de2c68a184c69aaebdf6b2ed02260",
            redirectURL: URL(string: "TurnTune://spotify-login-callback")!
        )
        config.tokenSwapURL = URL(string: "https://turntune-spotify-token-swap.herokuapp.com/api/token")!
        config.tokenRefreshURL = URL(string: "https://turntune-spotify-token-swap.herokuapp.com/api/refresh_token")!
        config.playURI = ""
        return SPTSessionManager(configuration: config, delegate: self)
    }()
    
    private var scope: SPTScope = [
        .appRemoteControl,
        .userReadCurrentlyPlaying,
        .userReadRecentlyPlayed,
        .userReadPlaybackState,
        .userModifyPlaybackState
    ]
    
    func initiateSession() {
        sessionManager.initiateSession(with: scope, options: .default)
    }
    
    func handleOpenURL(_ url: URL) {
        sessionManager.application(UIApplication.shared, open: url, options: [:])
    }
    
    func handleSessionManagerError(_ error: Error?) -> SPTErrorCode? {
        guard
            let error = error as NSError?
        else {
            print("No error")
            return nil
        }
        
        let errorCode = SPTErrorCode(rawValue: UInt(error.code))
        
        switch errorCode {
        case .authorizationFailed:
            print("authorizationFailedError")
        case .renewSessionFailed:
            print("renewSessionFailedError")
        case .jsonFailed:
            print("jsonFailedError")
        case .unknown:
            print("unknownError")
        default:
            print("Could not resolve errorCode")
        }
        
        return errorCode
    }
}

extension SpotifySessionManagerService: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("SPTSession didInitiate")
        delegate?.spotifySessionManagerService(didInitiate: session)
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("SPTSession didRenew")
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("SPTSession didFailWith error")
        _ = handleSessionManagerError(error)
    }
}
