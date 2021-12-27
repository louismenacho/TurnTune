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
    
    var spotifyConfig: SPTConfiguration?
    var spotifySessionManager: SPTSessionManager?
    var spotifyScope: SPTScope = [
        .appRemoteControl,
        .userReadCurrentlyPlaying,
        .userReadRecentlyPlayed,
        .userReadPlaybackState,
        .userModifyPlaybackState,
        .userReadPrivate
    ]
    
    func initSpotifyConfig(completion: @escaping (Result<Void, RepositoryError>) -> Void) {
        FirestoreRepository<SpotifyCredentials>(collectionPath: "spotify").get(id: "credentials") { result in
            completion( result.flatMap { credentials in
                let config = SPTConfiguration(clientID: credentials.clientID, redirectURL: URL(string: credentials.redirectURL)!)
                config.tokenSwapURL = URL(string: credentials.tokenSwapURL)
                config.tokenRefreshURL = URL(string: credentials.tokenRefreshURL)
                self.spotifyConfig = config
                return .success(())
            })
        }
    }
    
    func initSpotifySession(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let config = spotifyConfig else {
            print("Could not initiate Spotify session, Spotify config is nil")
            return
        }
        let spotifySessionManager = SPTSessionManager(configuration: config, delegate: self)
        self.spotifySessionManager = spotifySessionManager
        
        DispatchQueue.main.async {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.spotifySessionManager = spotifySessionManager
            spotifySessionManager.initiateSession(with: self.spotifyScope, options: .clientOnly)
        }
        
        spotifyInitiateSessionCompletion = { result in
            completion( result.flatMap { session in
                self.userProfileAPI.auth = .bearer(token: session.accessToken)
                return .success(())
            })
        }
    }
    
    func isCurrentSpotifyUserProfilePremium(completion: @escaping (Result<Bool, ClientError>) -> Void) {
        userProfileAPI.request(.currentUserProfile) { (result: Result<UserProfileResponse, ClientError>) in
            completion( result.flatMap { userProfile in
                .success(userProfile.product == "premium")
            })
        }
    }
    
    func spotifyButtonPressedAction(completion: @escaping (Result<Bool, Error>) -> Void) {
        let semaphore = DispatchSemaphore(value: 1)
        
        DispatchQueue.global().async { [self] in
            
            semaphore.wait()
            initSpotifyConfig { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success:
                    semaphore.signal()
                }
            }
            
            semaphore.wait()
            initSpotifySession { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success:
                    semaphore.signal()
                }
            }
            
            semaphore.wait()
            isCurrentSpotifyUserProfilePremium { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    return
                case let .success(isPremium):
                    semaphore.signal()
                    completion(.success(isPremium))
                }
            }
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

