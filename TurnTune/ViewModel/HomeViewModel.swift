//
//  HomeViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/23/21.
//

import Foundation

class HomeViewModel: NSObject {

    private var userProfileAPI = SpotifyAPIClient<SpotifyUserProfileAPI>()
    
    private var spotifyInitiateSessionCompletion: ((Result<SPTSession, Error>) -> Void)?
    
    var spotifySessionManager: SPTSessionManager? {
        willSet {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.spotifySessionManager = newValue
        }
    }
    
    var spotifyScope: SPTScope = [
        .appRemoteControl,
        .userReadCurrentlyPlaying,
        .userReadRecentlyPlayed,
        .userReadPlaybackState,
        .userModifyPlaybackState,
        .userReadPrivate
    ]
    
    func getSpotifyConfig(completion: @escaping (Result<SPTConfiguration, RepositoryError>) -> Void) {
        FirestoreRepository<SpotifyCredentials>(collectionPath: "spotify").get(id: "credentials") { result in
            completion( result.flatMap { credentials in
                let configuration = SPTConfiguration(clientID: credentials.clientID, redirectURL: URL(string: credentials.redirectURL)!)
                configuration.tokenSwapURL = URL(string: credentials.tokenSwapURL)
                configuration.tokenRefreshURL = URL(string: credentials.tokenRefreshURL)
                return .success(configuration)
            })
        }
    }
    
    func initiateSpotifySession(_ configuration: SPTConfiguration, completion: @escaping (Result<SPTSession, Error>) -> Void) {
        spotifySessionManager = SPTSessionManager(configuration: configuration, delegate: self)
        spotifySessionManager!.initiateSession(with: spotifyScope, options: .clientOnly)
        spotifyInitiateSessionCompletion = { result in
            completion( result.flatMap { session in
                self.userProfileAPI.auth = .bearer(token: session.accessToken)
                return .success(session)
            })
        }
    }
    
    func isCurrentUserProfilePremium(completion: @escaping (Result<Bool, ClientError>) -> Void) {
        userProfileAPI.request(.currentUserProfile) { (result: Result<UserProfileResponse, ClientError>) in
            completion( result.flatMap { userProfile in
                .success(userProfile.product == "premium")
            })
        }
    }
}

extension HomeViewModel: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("SPTSession didInitiate")
        spotifyInitiateSessionCompletion?(.success(session))
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("SPTSession didFailWith error")
        spotifyInitiateSessionCompletion?(.failure(error))
    }
}

