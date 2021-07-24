//
//  SpotifySessionManagerService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/26/21.
//

import Foundation

protocol SpotifySessionManagerServiceDelegate: AnyObject {
    func spotifySessionManagerService(didAuthorize newSession: SPTSession)
}


class SpotifySessionManagerService: NSObject {
    
    weak var delegate: SpotifySessionManagerServiceDelegate?
    
    private(set) lazy var config: SPTConfiguration = {
        let config = SPTConfiguration(
            clientID: "695de2c68a184c69aaebdf6b2ed02260",
            redirectURL: URL(string: "TurnTune://spotify-login-callback")!
        )
        config.tokenSwapURL = URL(string: "https://turntune-spotify-token-swap.herokuapp.com/api/token")!
        config.tokenRefreshURL = URL(string: "https://turntune-spotify-token-swap.herokuapp.com/api/refresh_token")!
        return config
    }()
    
    private(set) lazy var sessionManager: SPTSessionManager = {
        return SPTSessionManager(configuration: config, delegate: self)
    }()
    
    private var scope: SPTScope = [
        .appRemoteControl,
        .userReadCurrentlyPlaying,
        .userReadRecentlyPlayed,
        .userReadPlaybackState,
        .userModifyPlaybackState
    ]
    
    func initiateSession(with uri: String? = nil) {
        config.playURI = uri
        sessionManager = SPTSessionManager(configuration: config, delegate: self)
        sessionManager.initiateSession(with: scope, options: .default)
    }
    
    func renewSession() {
        sessionManager.renewSession()
    }
    
    func handleOpenURL(_ url: URL) {
        sessionManager.application(UIApplication.shared, open: url, options: [:])
    }
    
    func errorMessage(for error: Error) -> String {
        guard
            let error = error as NSError?,
            let errorCode = SPTErrorCode(rawValue: UInt(error.code))
        else {
            return error.localizedDescription
        }
        
        switch errorCode {
        case .authorizationFailed:
            return "authorizationFailedError"
        case .renewSessionFailed:
            return "renewSessionFailedError"
        case .jsonFailed:
            return "jsonFailedError"
        case .unknown:
            return "unknownError"
        default:
            return "Could not resolve errorCode"
        }
    }
}

extension SpotifySessionManagerService: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("SPTSession didInitiate")
        delegate?.spotifySessionManagerService(didAuthorize: session)
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("SPTSession didRenew")
        delegate?.spotifySessionManagerService(didAuthorize: session)
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("SPTSession didFailWith error")
        print(errorMessage(for: error))
    }
}
