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
    
    var currentMember: Member?
    var currentRoom: Room?
    var currentRoomID: String = ""
    
    var spotifySessionManager: SPTSessionManager?
    var spotifyInitiateSessionCompletion: ((Result<Void, Error>) -> Void)?
    
    var spotifyConfig: SPTConfiguration?
    var spotifyScope: SPTScope = [
        .appRemoteControl,
        .userReadCurrentlyPlaying,
        .userReadRecentlyPlayed,
        .userReadPlaybackState,
        .userModifyPlaybackState,
        .userReadPrivate
    ]
    
    func createRoom(hostName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async { [self] in
            
            initSpotifySessionManager { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success:
                    print("initSpotifySessionManager complete")
                    semaphore.signal()
                }
            }
            semaphore.wait()
            
            initSpotifySession { result in
                semaphore.signal()
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success:
                    print("initSpotifySession complete")
                }
            }
            let timeoutResult = semaphore.wait(timeout: .now() + 10)
            if case .timedOut = timeoutResult {
                completion(.failure(AppError.message("Could not initiate Spotify session")))
                return
            } else if spotifySessionManager?.session == nil {
                return
            }
            
            getSpotifyUserSubscription { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success(let subscription):
                    print("getSpotifyUserSubscription complete")
                    if subscription != "premium" {
                        completion(.failure(AppError.message("You must have a Spotify Premium account to continue")))
                        return
                    }
                    semaphore.signal()
                }
            }
            semaphore.wait()
            
            generateNewRoomID { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success:
                    print("generateNewSessionID complete")
                    semaphore.signal()
                }
            }
            semaphore.wait()
            
            createNewRoom(hostName: hostName) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success:
                    print("createNewSession complete")
                    semaphore.signal()
                }
            }
            semaphore.wait()
            
            completion(.success(()))
        }
    }
    
    func joinRoom(roomID: String, memberName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async { [self] in
            
            findRoom(id: roomID) { result in
                switch result {
                case .failure(let error):
                    if let error = error as? RepositoryError, case .notFound = error {
                        completion(.failure(AppError.message("Room not found")))
                    } else {
                        completion(.failure(error))
                    }
                case .success:
                    print("findRoom complete")
                    semaphore.signal()
                }
            }
            semaphore.wait()
            
            findExistingMember { result in
                switch result {
                case .failure(let error):
                    if let error = error as? RepositoryError, case .notFound = error {
                        print("findMember notFound")
                        semaphore.signal()
                    } else {
                        completion(.failure(error))
                    }
                case .success:
                    print("findMember complete")
                    semaphore.signal()
                }
            }
            semaphore.wait()
            
            if currentMember == nil {
                addNewRoomMember(memberName: memberName) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success:
                        print("addRoomMember complete")
                        semaphore.signal()
                    }
                }
                semaphore.wait()
                
                updateRoom { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success:
                        print("updateRoom complete")
                        semaphore.signal()
                    }
                }
                semaphore.wait()
            }
            
            initSpotifySessionManager { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success:
                    print("initSpotifySessionManager complete")
                    semaphore.signal()
                }
            }
            semaphore.wait()
            
            if let currentRoom = currentRoom, Date() >= currentRoom.spotifyTokenExpirationDate && currentMember == currentRoom.host {
                initSpotifySession { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success:
                        print("initSpotifySession complete")
                        semaphore.signal()
                    }
                }
                semaphore.wait()
                
                updateRoom { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success:
                        print("updateRoom complete")
                        semaphore.signal()
                    }
                }
                semaphore.wait()
                
            }
            
            completion(.success(()))
        }
    }
    
    private func initSpotifySessionManager(completion: @escaping (Result<Void, Error>) -> Void) {
        FirestoreRepository<SpotifyCredentials>(collectionPath: "spotify").get(id: "credentials") { result in
            completion( result.flatMap { credentials in
                let config = SPTConfiguration(clientID: credentials.clientID, redirectURL: URL(string: credentials.redirectURL)!)
                config.tokenSwapURL = URL(string: credentials.tokenSwapURL)
                config.tokenRefreshURL = URL(string: credentials.tokenRefreshURL)
                self.spotifyConfig = config
                self.spotifySessionManager = SPTSessionManager(configuration: config, delegate: self)
                return .success(())
            }.flatMapError { error in
                return .failure(AppError.message(error.localizedDescription))
            })
        }
    }
    
    private func initSpotifySession(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let spotifySessionManager = spotifySessionManager else {
            completion(.failure(AppError.message("Could not initiate Spotify session")))
            return
        }
        DispatchQueue.main.async {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.spotifySessionManager = spotifySessionManager
            spotifySessionManager.initiateSession(with: self.spotifyScope, options: .clientOnly)
        }
        spotifyInitiateSessionCompletion = { result in
            completion(result)
        }
    }
    
    private func getSpotifyUserSubscription(completion: @escaping (Result<String, Error>) -> Void) {
        guard let spotifySession = spotifySessionManager?.session else {
            print("Could not get Spotify user profile")
            completion(.failure(AppError.message("")))
            return
        }
        let spotifyUserProfileAPI = SpotifyAPIClient<SpotifyUserProfileAPI>()
        spotifyUserProfileAPI.auth = .bearer(token: spotifySession.accessToken)
        spotifyUserProfileAPI.request(.currentUserProfile) { (result: Result<UserProfileResponse, ClientError>) in
            completion(result.flatMap { userProfile in
                    return .success((userProfile.product))
                }.flatMapError { error in
                    return .failure(AppError.message(error.localizedDescription))
                })
        }
    }
    
    private func generateNewRoomID(completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signInAnonymously { authDataResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let newID = self.generateRandomCode(length: 4)
            FirestoreRepository<Room>(collectionPath: "rooms").get(id: newID) { result in
                switch result {
                case .failure(let error):
                    if case .notFound = error {
                        print("\(newID) does not exist. Using for new room")
                        self.currentRoomID = newID
                        completion(.success(newID))
                    } else {
                        completion(.failure(error))
                    }
                case .success:
                    print("Room\(newID) already exists. Regenerating room code")
                    self.generateNewRoomID(completion: completion)
                }
            }
        }
    }
    
    private func createNewRoom(hostName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser, let spotifySession = spotifySessionManager?.session else {
            completion(.failure(AppError.message("Could not create new room")))
            return
        }
        let host = Member(documentID: currentUser.uid, id: currentUser.uid, displayName: hostName ,isHost: true)
        let room = Room(documentID: currentRoomID, id: currentRoomID, host: host, spotifyToken: spotifySession.accessToken, spotifyTokenExpirationDate: spotifySession.expirationDate)
        let group = DispatchGroup()
        
        group.enter()
        FirestoreRepository<Room>(collectionPath: "rooms").create(room) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.currentRoom = room
            group.leave()
        }
        
        group.enter()
        FirestoreRepository<Member>(collectionPath: "rooms/"+currentRoomID+"/members").create(host) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.currentMember = host
            group.leave()
        }
        
        group.notify(queue: .global()) {
            completion(.success(()))
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
    
    private func findRoom(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signInAnonymously { authDataResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            FirestoreRepository<Room>(collectionPath: "rooms").get(id: id) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    return
                case .success(let room):
                    self.currentRoom = room
                    self.currentRoomID = room.id
                    completion(.success(()))
                }
            }
        }
    }
    
    private func findExistingMember(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentRoom = currentRoom, let currentUser = Auth.auth().currentUser else {
            completion(.failure(AppError.message("Could not find existing member")))
            return
        }
        FirestoreRepository<Member>(collectionPath: "rooms/"+currentRoom.id+"/members").get(id: currentUser.uid) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(let member):
                self.currentMember = member
                completion(.success(()))
            }
        }
    }
    
    private func addNewRoomMember(memberName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard var currentRoom = currentRoom, let currentUser = Auth.auth().currentUser else {
            completion(.failure(AppError.message("Could not add new room member")))
            return
        }
        if currentRoom.memberCount == 2 {
            completion(.failure(AppError.message("Room limit reached")))
            return
        }
        let newMember = Member(documentID: currentUser.uid, id: currentUser.uid, displayName: memberName, isHost: false)
        currentRoom.memberCount += 1
        FirestoreRepository<Member>(collectionPath: "rooms/"+currentRoom.id+"/members").create(newMember) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.currentMember = newMember
            self.currentRoom = currentRoom
            completion(.success(()))
        }
    }
    
    private func updateRoom(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentRoom = currentRoom else {
            completion(.failure(AppError.message("Could not update room")))
            return
        }
        FirestoreRepository<Room>(collectionPath: "rooms").update(currentRoom) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

extension HomeViewModel: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("sessionManager did initiate session in Home view")
        currentRoom?.spotifyToken = session.accessToken
        spotifyInitiateSessionCompletion?(.success(()))
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("sessionManager did fail with error in Home view")
        spotifyInitiateSessionCompletion?(.failure(error))
    }
}

