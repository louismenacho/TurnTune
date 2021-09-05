//
//  HomeViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/3/21.
//

import Foundation

class HomeViewModel {
    
    private(set) var authService = FirebaseAuthService()
    private(set) var roomDataAccess = RoomDataAccessProvider()
    private(set) var memberDataAccess = MemberDataAccessProvider()
    private(set) var musicBrowserService = SpotifyMusicBrowserService()
    private(set) var musicPlayerService = SpotifyMusicPlayerService()
    
    init() {
        authService.delegate = self
        roomDataAccess.delegate = self
        memberDataAccess.delegate = self
        musicPlayerService.delegate = self
    }

    func joinRoom(roomID: String, as displayName: String, completion: @escaping () -> Void) {
        authService.signIn { [self] in
            roomDataAccess.getRoom(roomID) { [self] room in
                let member = Member(userID: authService.currentUserID, displayName: displayName)
                memberDataAccess.addMember(member)
                completion()
            }
        }
    }
    
    func hostRoom(as displayName: String, completion: @escaping () -> Void) {
        authService.signIn { [self] in
            let host = Member(userID: authService.currentUserID, displayName: displayName)
            roomDataAccess.createRoom(host: host) { [self] room in
                memberDataAccess.addMember(host)
                completion()
            }
        }
    }
    
    func connectMusicBrowserService(completion: (() -> Void)? = nil) {
        musicBrowserService.initiate {
            completion?()
        }
    }
    
    func connectMusicPlayerService(completion: @escaping () -> Void) {
        musicPlayerService.initiate {
            completion()
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
        print(error)
    }
}

extension HomeViewModel: DataAccessProviderDelegate {
    func dataAccessProvider(_ dataAccessProvider: DataAccessProvider, error: DataAccessError) {
        print(error)
    }
}

extension HomeViewModel: MusicPlayerServiceableDelegate {
    func musicPlayerServiceable(error: MusicPlayerServiceableError) {
        print(error)
    }
}
