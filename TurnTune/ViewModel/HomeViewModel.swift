//
//  HomeViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/3/21.
//

import Foundation

class HomeViewModel: ViewModel {
    
    var delegate: ViewModelDelegate?
    
    private(set) var authService = FirebaseAuthService()
    private(set) var musicBrowserService = SpotifyMusicBrowserService()
    private(set) var spotifyMusicPlayerService: SpotifyMusicPlayerService?
    
    private(set) var roomDataAccess = RoomDataAccessProvider()
    private(set) var memberDataAccess = MemberDataAccessProvider()
    private(set) var playerStateDataAccess = PlayerStateDataAccessProvider()
    private(set) var spotifyCredentialsDataAccess = SpotifyCredentialsDataAccessProvider()
    
    private(set) var userDefaults = UserDefaultsRepository()
    
    var userIsHost: Bool {
        userDefaults.isHost
    }
    
    var userDisplayName: String {
        userDefaults.displayName
    }
    
    var userRoomID: String {
        userDefaults.roomID
    }
    
    init() {
        authService.delegate = self
        roomDataAccess.delegate = self
        memberDataAccess.delegate = self
        playerStateDataAccess.delegate = self
        musicBrowserService.delegate = self
    }

    func joinRoom(roomID: String, as displayName: String, completion: @escaping () -> Void) {
        authService.signIn { [self] in
            roomDataAccess.getRoom(roomID) { [self] room in
                userDefaults.roomID = roomID
                userDefaults.userID = authService.currentUserID
                userDefaults.displayName = displayName
                userDefaults.isHost = authService.currentUserID == room.host.userID
                
                let member = Member(
                    userID: userDefaults.userID,
                    displayName: userDefaults.displayName,
                    isHost: userDefaults.isHost
                )
                memberDataAccess.addMember(member) {
                    completion()
                }
            }
        }
    }
    
    func rejoinRoom(completion: @escaping (Room, Member) -> Void) {
        authService.signIn { [self] in
            roomDataAccess.getRoom(userRoomID) { [self] room in
                memberDataAccess.getMember(authService.currentUserID) { member in
                    completion(room, member)
                }
            }
        }
    }
        
    func hostRoom(as displayName: String, completion: @escaping () -> Void) {
        authService.signIn { [self] in
            let host = Member(
                userID: authService.currentUserID,
                displayName: displayName,
                isHost: true
            )
            roomDataAccess.createRoom(host: host) { [self] room in
                userDefaults.userID = authService.currentUserID
                userDefaults.roomID = room.roomID
                userDefaults.displayName = host.displayName
                
                memberDataAccess.addMember(host) {
                    completion()
                }
                playerStateDataAccess.createPlayerState(playerState: PlayerState())
            }
        }
    }
    
    func connectMusicBrowserService(completion: (() -> Void)? = nil) {
        musicBrowserService.initiate {
            completion?()
        }
    }
    
    func connectMusicPlayerService(completion: @escaping () -> Void) {
        spotifyCredentialsDataAccess.getSpotifyCredentials { [self] credentials in
            spotifyMusicPlayerService = SpotifyMusicPlayerService(credentials: credentials)
            spotifyMusicPlayerService!.delegate = self
            spotifyMusicPlayerService!.initiateSession { [self] in
                spotifyMusicPlayerService!.isCurrentUserProfilePremium { isPremium in
                    if isPremium {
                        completion()
                    }
                }
            }
        }
    }

    private func isNameValid(name: String) -> Bool {
        if name.isEmpty || name.count > 12 {
            print("Invalid name")
            return false
        }
        return true
    }
}

extension HomeViewModel: AuthenticationServiceableDelegate {
    func authenticationServiceable(_ authenticationServiceable: AuthenticationServiceable, error: AuthenticationError) {
        delegate?.viewModel(self, error: .authenticationError(error: error))
    }
}

extension HomeViewModel: DataAccessProviderDelegate {
    func dataAccessProvider(_ dataAccessProvider: DataAccessProvider, error: DataAccessError) {
        delegate?.viewModel(self, error: .dataAccessError(error: error))
    }
}

extension HomeViewModel: MusicPlayerServiceableDelegate {
    func musicPlayerServiceable(error: MusicPlayerError) {
        delegate?.viewModel(self, error: .musicPlayerError(error: error))
    }
}

extension HomeViewModel: MusicBrowserServiceableDelegate {
    func musicBrowserServiceable(error: MusicBrowserError) {
        delegate?.viewModel(self, error: .musicBrowserError(error: error))
    }
}
