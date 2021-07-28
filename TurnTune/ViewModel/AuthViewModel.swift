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
        
        // Authenticate user
        FirebaseAuthService().signIn { error in
            if let error = error {
                print("signIn: \(error)")
            }
            
            // Set user display name
            FirebaseAuthService().setDisplayName(displayName) { error in
                if let error = error {
                    print("setDisplayName: \(error)")
                }
            }
            
            // Find room and save the current room in User Defaults
            RoomService().getRoom(roomID) { roomResult in
                switch roomResult {
                case .failure(let error):
                    print("getExistingRoom: \(error)")
                case .success(let room):
                    RoomService().saveRoomID(room.roomID)
                    
                    // Add user as a member to the current room
                    MemberService().addMember(FirebaseAuthService().currentUser) { error in
                        if let error = error {
                            print("addMember: \(error)")
                        }
                        
                        // Completion of tasks
                        completion()
                    }
                }
            }
            
        }
    }
    
    func hostRoom(as displayName: String, completion: @escaping () -> Void) {
        
        // Authenticate user
        FirebaseAuthService().signIn { error in
            if let error = error {
                print("signIn: \(error)")
            }
            
            // Set user display name
            FirebaseAuthService().setDisplayName(displayName) { error in
                if let error = error {
                    print("setDisplayName: \(error)")
                }
            }
            
            // Create room and save the current room in User Defaults
            RoomService().createRoom(host: FirebaseAuthService().currentUser) { roomResult in
                switch roomResult {
                case .failure(let error):
                    print("createRoom: \(error)")
                case .success(let room):
                    RoomService().saveRoomID(room.roomID)
                    
                    // Add user as a member to the current room
                    MemberService().addMember(FirebaseAuthService().currentUser) { error in
                        if let error = error {
                            print("addMember: \(error)")
                        }
                        
                        // Completion of tasks
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
