//
//  AuthViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/3/21.
//

import Foundation

class AuthViewModel {
    
    private var authentication = FirebaseAuthService()
    private var roomProvider = RoomProviderService()
    
    private(set) var roomManager: RoomManagerService?

    func joinRoom(roomId: String, as displayName: String, completion: @escaping () -> Void) {
        authentication.signIn(displayName: displayName) { [self] userResult in
            switch userResult {
            case let .failure(error):
                print("signIn: \(error)")
                return
                
                
            case let .success(user):
                roomProvider.getExistingRoom(roomId: roomId) { roomResult in
                    if case let .failure(error) = roomResult {
                        print("getExistingRoom: \(error)")
                        return
                    }
                    
                    let roomManager = RoomManagerService(roomId: roomId)
                    roomManager.addMember(Member(id: user.uid, displayName: user.displayName!)) { error in
                        if let error = error {
                            print("addMember: \(error)")
                            return
                        }
                        
                        self.roomManager = roomManager
                        completion()
                    }
                }
            }
        }
    }
    
    func hostRoom(as displayName: String, completion: @escaping () -> Void) {
        authentication.signIn(displayName: displayName) { [self] userResult in
            switch userResult {
            case let .failure(error):
                print("signIn: \(error)")
                return
                
            case let .success(user):
                roomProvider.createNewRoom(host: user.uid) { roomResult in
                    switch roomResult {
                    case let .failure(error):
                        print("createNewRoom: \(error)")
                        return
                    case let .success(room):
                        
                        let roomManager = RoomManagerService(roomId: room.id!)
                        roomManager.addMember(Member(id: user.uid, displayName: user.displayName!)) { error in
                            if let error = error {
                                print("addMember: \(error)")
                            }
                            
                            self.roomManager = roomManager
                            completion()
                        }
                    }
                }
            }
        }
    }
    
}
