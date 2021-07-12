//
//  RoomViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/18/21.
//

//import Foundation
//import Firebase
//import FirebaseFirestoreSwift
//
//protocol RoomViewModelDelegate: AnyObject {
//    func roomViewModel(roomViewModel: RoomViewModel, didInitialize: Bool)
//    func roomViewModel(roomViewModel: RoomViewModel, didUpdate room: Room)
//    func roomViewModel(roomViewModel: RoomViewModel, didUpdate members: [Member])
//    func roomViewModel(roomViewModel: RoomViewModel, didUpdate queue: [Song])
//}
//
//protocol RoomViewModelMembersDelegate: AnyObject {
//    func roomViewModel(roomViewModel: RoomViewModel, didUpdate members: [Member])
//}

//class RoomViewModel {
//
//    // Delegates
//    weak var delegate: RoomViewModelDelegate?
//    weak var membersDelegate: RoomViewModelMembersDelegate?
//
//
//    // Models
//    private(set) var room: Room?
//    private(set) var members = [Member]()
//    private(set) var queue = [Song]()
//
//    // Firestore
//    private(set) var roomPath: String
//    private(set) lazy var membersCollectionPath = roomPath+"/members"
//    private(set) lazy var queueCollectionPath = roomPath+"/queue"
//    private(set) var firestore = FirebaseFirestore.shared
//
//    // Spotify
//    private var spotifySessionManager = SpotifySessionManager.shared
//    private var spotifyAppRemote = SpotifyAppRemote.shared
//    private var spotifyWebAPI = SpotifyAPI.shared
//
//    // Computed
//    var currentMember: Member? { members.first { $0.id == Auth.auth().currentUser?.uid } }
//
//    init(roomPath: String) {
//        self.roomPath = roomPath
//        loadFirestoreData(completion:) { [self] in
//            self.addFirestoreListeners()
//
//            if room?.hostId == currentMember?.id {
//                spotifySessionManager.initiateSession()
//                spotifyAppRemote.delegate = self
//            }
//        }
//    }
//
//    func setRoomPlayingSong(_ song: Song, completion: (() -> Void)? = nil) {
//        room?.playingSong = song
//        firestore.setData(from: room, in: roomPath) { error in
//            if let error = error {
//                print(error)
//            }
//            completion?()
//        }
//    }
//
//    func queueSong(_ song: Song, completion: (() -> Void)? = nil) {
//        var queueSong = song
//        queueSong.orderGroup = queue.filter({ $0.addedBy?.id == currentMember?.id }).count
//        queueSong.addedBy = currentMember
//        firestore.appendData(from: queueSong, in: queueCollectionPath) { error in
//            if let error = error {
//                print(error)
//            }
//            completion?()
//        }
//    }
//
//    // Spotify Player Methods
//
//    func play(_ song: Song, completion: (() -> Void)? = nil) {
//        spotifyWebAPI.playTrack(uris: [song.spotifyURI!]) { error in
//            if let error = error {
//                print(error)
//            }
//            completion?()
//        }
//    }
//
//    func pause(completion: (() -> Void)? = nil) {
//        spotifyWebAPI.pausePlayback { error in
//            if let error = error {
//                print(error)
//            }
//            completion?()
//        }
//    }
//
//    private func loadFirestoreData(completion: @escaping () -> Void) {
//        let group = DispatchGroup()
//
//        group.enter()
//        firestore.getDocumentData(documentPath: roomPath) { (result: Result<Room, Error>) in
//            switch result {
//            case let .failure(error):
//                print(error)
//            case let .success(room):
//                self.room = room
//            }
//            group.leave()
//        }
//
//        group.enter()
//        firestore.getCollectionData(collectionPath: membersCollectionPath, orderBy: "dateJoined") { (result: Result<[Member], Error>) in
//            switch result {
//            case let .failure(error):
//                print(error)
//            case let .success(members):
//                self.members = members
//            }
//            group.leave()
//        }
//
//        group.enter()
//        firestore.getCollectionData(collectionPath: queueCollectionPath, whereField: ("didPlay", false), orderBy: ["orderGroup", "dateAdded"]) { (result: Result<[Song], Error>) in
//            switch result {
//            case let .failure(error):
//                print(error)
//            case let .success(queue):
//                self.queue = queue
//            }
//            group.leave()
//        }
//
//        group.notify(queue: .main) {
//            self.delegate?.roomViewModel(roomViewModel: self, didInitialize: true)
//            completion()
//        }
//    }
//
//    private func addFirestoreListeners() {
//        firestore.addDocumentListener(documentPath: roomPath) { (result: Result<Room, Error>) in
//            switch result {
//            case let .failure(error):
//                print(error)
//            case let .success(room):
//                self.room = room
//                self.delegate?.roomViewModel(roomViewModel: self, didUpdate: room)
//            }
//        }
//
//        firestore.addCollectionListener(collectionPath: membersCollectionPath, orderBy: "dateJoined") { (result: Result<[Member], Error>) in
//            switch result {
//            case let .failure(error):
//                print(error)
//            case let .success(members):
//                self.members = members
//                self.delegate?.roomViewModel(roomViewModel: self, didUpdate: members)
//                self.membersDelegate?.roomViewModel(roomViewModel: self, didUpdate: members)
//            }
//        }
//
//        firestore.addCollectionListener(collectionPath: queueCollectionPath, whereField: ("didPlay", false), orderBy: ["orderGroup", "dateAdded"]) { (result: Result<[Song], Error>) in
//            switch result {
//            case let .failure(error):
//                print(error)
//            case let .success(queue):
//                self.queue = queue
//                self.delegate?.roomViewModel(roomViewModel: self, didUpdate: queue)
//            }
//        }
//    }
//}

//extension RoomViewModel: SpotifyAppRemoteDelegate {
//    func spotifyAppRemote(spotifyAppRemote: SpotifyAppRemote, trackDidChange newTrack: SPTAppRemoteTrack) {
//        if let nextSong = queue.filter({ $0.spotifyURI == newTrack.uri }).first {
//            setRoomPlayingSong(nextSong)
//        }
//    }
//    
//    func spotifyAppRemote(spotifyAppRemote: SpotifyAppRemote, trackDidFinish track: SPTAppRemoteTrack) {
//        print(queue.count)
//        if !queue.isEmpty {
//            let song = queue.removeFirst()
//            play(song) {
//                Firestore.firestore().document(self.queueCollectionPath+"/"+song.id!).delete()
//            }
//        }
//    }
//}
