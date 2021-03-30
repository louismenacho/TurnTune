//
//  SpotifySessionManager.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/28/21.
//

import Foundation

class SpotifySessionManager: NSObject {
    
    private(set) static var shared = SpotifySessionManager()
    
    private let sessionManager: SPTSessionManager
    
    var session: SPTSession? { sessionManager.session }
    
    var scope: SPTScope = [
        .appRemoteControl,
        .userReadCurrentlyPlaying,
        .userReadPlaybackState,
        .userModifyPlaybackState
    ]
    
    private override init() {
        sessionManager = SPTSessionManager(configuration: SpotifyApp.shared.configuration, delegate: nil)
    }
    
    func initiateSession() {
        sessionManager.delegate = self
        sessionManager.initiateSession(with: scope, options: .default)
    }
    
    func handleOpenURL(_ url: URL) {
        sessionManager.application(UIApplication.shared, open: url, options: [:])
    }
    
    func handleError(_ error: Error?) -> SPTErrorCode? {
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

extension SpotifySessionManager: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("SPTSession didInitiate")
        SpotifyAppRemote.shared.setAccessToken(session.accessToken)
        #warning("set in firestore")
        Spotify.APIToken.accessToken = session.accessToken
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("SPTSession didRenew")
        SpotifyAppRemote.shared.setAccessToken(session.accessToken)
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("SPTSession didFailWith error")
        _ = handleError(error)
    }
}
