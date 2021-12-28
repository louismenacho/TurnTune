//
//  HomeViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/23/21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class HomeViewModel: NSObject {
    
    var session: Session?
    var spotifySessionManager: SPTSessionManager?

    private var spotifyUserProfileAPI = SpotifyAPIClient<SpotifyUserProfileAPI>()
    private var spotifyInitiateSessionCompletion: ((Result<SPTSession, Error>) -> Void)?
    private var spotifyConfig: SPTConfiguration?
    private var spotifyUserSubscription: String = ""
    private var spotifyScope: SPTScope = [
        .appRemoteControl,
        .userReadCurrentlyPlaying,
        .userReadRecentlyPlayed,
        .userReadPlaybackState,
        .userModifyPlaybackState,
        .userReadPrivate
    ]
    
    private func initSpotifyConfig(completion: @escaping (Result<Void, RepositoryError>) -> Void) {
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
    
    private func initSpotifySession(completion: @escaping (Result<Void, Error>) -> Void) {
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
                self.spotifyUserProfileAPI.auth = .bearer(token: session.accessToken)
                return .success(())
            })
        }
    }
    
    private func initSpotifyUserSubscription(completion: @escaping (Result<Void, ClientError>) -> Void) {
        spotifyUserProfileAPI.request(.currentUserProfile) { (result: Result<UserProfileResponse, ClientError>) in
            completion( result.flatMap { userProfile in
                self.spotifyUserSubscription = userProfile.product
                return .success(())
            })
        }
    }
    
    private func initSession(completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signInAnonymously { authDataResult, error in
            guard let authData = authDataResult else {
                if let error = error {
                    completion(.failure(error))
                }
                print("AuthDataResult is nil")
                return
            }
            
            self.generatetNewSessionCode { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case let .success(newCode):
                    let member = Member(documentID: authData.user.uid, id: authData.user.uid, isHost: true)
                    self.session = Session(documentID: newCode, id: newCode, host: member)
                    completion(.success(()))
                }
            }
        }
    }
    
    private func saveSession(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let session = session else {
            print("Could not save session, session is nil")
            return
        }
        FirestoreRepository<Session>(collectionPath: "sessions").create(session) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func saveHost(name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard var session = session else {
            print("Could not save host, session is nil")
            return
        }
        session.host.displayName = name
        FirestoreRepository<Member>(collectionPath: "sessions/"+session.id+"/members").create(session.host) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func generatetNewSessionCode(completion: @escaping (Result<String, RepositoryError>) -> Void) {
        let newCode = generateRandomCode(length: 4)
        FirestoreRepository<Session>(collectionPath: "sessions").get(id: newCode) { result in
            switch result {
            case .failure(let error):
                if case .notFound = error {
                    print("\(newCode) does not exist. Using for new room")
                    completion(.success(newCode))
                }
            case .success:
                print("\(newCode) already exists. Regenerating room code")
                self.generatetNewSessionCode(completion: completion)
            }
        }
    }
    
    private func generateRandomCode(length: Int) -> String {
        let alphabeticRange = 65...90
        var code = ""
        while code.count < length {
            let unicodeScalar = Int.random(in: alphabeticRange)
            let letter = Character(UnicodeScalar(unicodeScalar)!)
            code = "\(code)\(letter)"
        }
        return code
    }
    
    func createRoom(hostName: String, completion: @escaping (Result<Void, Error>) -> Void) {
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
            initSpotifyUserSubscription { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success:
                    semaphore.signal()
                }
            }
            
            semaphore.wait()
            initSession { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success:
                    semaphore.signal()
                }
            }
            
            semaphore.wait()
            saveSession { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success:
                    semaphore.signal()
                }
            }
            
            semaphore.wait()
            saveHost(name: hostName) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success:
                    semaphore.signal()
                    completion(.success(()))
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

