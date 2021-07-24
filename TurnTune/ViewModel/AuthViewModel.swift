//
//  AuthViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/3/21.
//

import Foundation

class AuthViewModel {
    
    private(set) var authService = FirebaseAuthService()
    private(set) var roomService = RoomService()
    private(set) var memberService = MemberService()

    func joinRoom(roomID: String, as displayName: String, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        authService.signIn { error in
            if let error = error {
                print("signIn: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        authService.setDisplayName(displayName) { error in
            if let error = error {
                print("setDisplayName: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        roomService.getRoom(roomID) { roomResult in
            switch roomResult {
            case .failure(let error):
                print("getExistingRoom: \(error)")
            case .success(let room):
                self.roomService.setCurrentRoomID(room.roomID)
            }
            group.leave()
        }
        
        group.enter()
        memberService.addMember(authService.currentUser) { error in
            if let error = error {
                print("addMember: \(error)")
            }
            group.leave()
        }
        
        completion()
    }
    
    func hostRoom(as displayName: String, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        authService.signIn { error in
            if let error = error {
                print("signIn: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        authService.setDisplayName(displayName) { error in
            if let error = error {
                print("setDisplayName: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        roomService.createRoom(host: authService.currentUser) { roomResult in
            switch roomResult {
            case .failure(let error):
                print("createRoom: \(error)")
            case .success(let room):
                self.roomService.setCurrentRoomID(room.roomID)
            }
            group.leave()
        }
        
        group.enter()
        memberService.addMember(authService.currentUser) { error in
            if let error = error {
                print("addMember: \(error)")
            }
            group.leave()
        }
        
        completion()
    }
    
    private func isNameValid(name: String) -> Bool {
        if name.isEmpty || name.count > 12 {
            print("Invalid name")
            return false
        }
        return true
    }
    
}
