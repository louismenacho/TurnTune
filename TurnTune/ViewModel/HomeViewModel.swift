//
//  HomeViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/23/21.
//

import Combine
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
    
    var cancellable: AnyCancellable?
    
    var spotifyCancellable: AnyCancellable?
    var spotifyInitiateSessionSubject = PassthroughSubject<SPTSession, Error>()
    
    func create(hostName: String, onCompletion: @escaping (Error?) -> Void) {
        var room = Room()
        cancellable =
        self.getSpotifyConfiguration()
        
            .flatMap { config in
                self.initiateSpotifySession(config: config)
            }
        
            .flatMap { session -> Future<String, Error> in
                room.spotifyToken = session.accessToken
                room.spotifyTokenExpirationDate = session.expirationDate
                return self.getSpotifyUserSubscription(session: session)
            }
        
            .flatMap { subscription -> Future<User, Error> in
                if subscription != "premium" {
                    return Future<User, Error> { $0(.failure(AppError.spotifySubscriptionError)) }
                } else {
                    return self.authenticate()
                }
            }
        
            .flatMap { user -> Future<String, Error> in
                let host = Member(documentID: user.uid, id: user.uid, displayName: hostName, isHost: true)
                room.host = host
                return self.generateRoomCode()
            }
        
            .flatMap { newRoomCode -> Future<Void, Error> in
                room.documentID = newRoomCode
                room.id = newRoomCode
                return self.createRoom(room)
            }
        
            .sink { completion in
                switch completion {
                case.failure(let error):
                    onCompletion(error)
                case .finished:
                    onCompletion(nil)
                }
            } receiveValue: {
                self.currentRoom = room
                self.currentMember = room.host
            }
    }
    
    func authenticate() -> Future<User, Error> {
        Future { promise in
            Auth.auth().signInAnonymously { authData, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(authData!.user))
                }
            }
        }
    }
    
    func getSpotifyConfiguration() -> Future<SPTConfiguration, Error> {
        Future { promise in
            FirestoreRepository<SpotifyConfiguration>(collectionPath: "spotify").get(id: "configuration") { result in
                promise( result.flatMap { configuration in
                    let config = SPTConfiguration(clientID: configuration.clientID, redirectURL: URL(string: configuration.redirectURL)!)
                    config.tokenSwapURL = URL(string: configuration.tokenSwapURL)
                    config.tokenRefreshURL = URL(string: configuration.tokenRefreshURL)
                    return .success(config)
                }.flatMapError { error in
                    return .failure(AppError.message(error.localizedDescription))
                })
            }
        }
    }
    
    func initiateSpotifySession(config: SPTConfiguration) -> Future<SPTSession, Error> {
        Future { [self] promise in
            let sessionManager = SPTSessionManager(configuration: config, delegate: self)
            guard sessionManager.isSpotifyAppInstalled else {
                promise(.failure(AppError.spotifyAppNotFoundError))
                return
            }
            DispatchQueue.main.async {
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                sceneDelegate?.spotifyConfiguration = config
                sceneDelegate?.spotifySessionManager = sessionManager
                sessionManager.initiateSession(with: self.spotifyScope, options: .clientOnly)
            }
            spotifyCancellable = spotifyInitiateSessionSubject
            .sink { completion in
                if case let .failure(error) = completion {
                    promise(.failure(error))
                }
            } receiveValue: { session in
                promise(.success(session))
            }
        }
    }
    
    func getSpotifyUserSubscription(session: SPTSession) -> Future<String, Error> {
        Future { promise in
            let spotifyUserProfileAPI = SpotifyAPIClient<SpotifyUserProfileAPI>(auth: .bearer(token: session.accessToken))
            spotifyUserProfileAPI.request(.currentUserProfile) { (result: Result<UserProfileResponse, ClientError>) in
                promise( result.flatMap { userProfile in
                    return .success((userProfile.product))
                }.flatMapError { error in
                    return .failure(AppError.message(error.localizedDescription))
                })
            }
        }
    }
    
    func generateRoomCode() -> Future<String, Error> {
        Future { promise in
            self.generateNewRoomCode { result in
                promise(result)
            }
        }
    }
    
    func createRoom(_ room: Room) -> Future<Void, Error> {
        Future { promise in
            let group = DispatchGroup()

            group.enter()
            FirestoreRepository<Room>(collectionPath: "rooms").create(room) { error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                group.leave()
            }
            
            group.enter()
            FirestoreRepository<Member>(collectionPath: "rooms/"+room.id+"/members").create(room.host) { error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                group.leave()
            }
            
            group.notify(queue: .global()) {
                promise(.success(()))
            }
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
        FirestoreRepository<SpotifyConfiguration>(collectionPath: "spotify").get(id: "credentials") { result in
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
    
    private func generateNewRoomCode(completion: @escaping (Result<String, Error>) -> Void) {
        let newCode = self.generateRandomCode(length: 4)
        FirestoreRepository<Room>(collectionPath: "rooms").get(id: newCode) { result in
            switch result {
            case .failure(let error):
                if case .notFound = error {
                    print("\(newCode) does not exist. Using for new room")
                    self.currentRoomID = newCode
                    completion(.success(newCode))
                } else {
                    completion(.failure(error))
                }
            case .success:
                print("Room\(newCode) already exists. Regenerating room code")
                self.generateNewRoomCode(completion: completion)
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
        spotifyInitiateSessionSubject.send(session)
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("sessionManager did fail with error in Home view")
        spotifyInitiateSessionSubject.send(completion: .failure(error))
    }
}

