//
//  SettingsViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/21/21.
//

import Foundation

class SettingsViewModel {
    
    private(set) var authService = FirebaseAuthService()
    private(set) var roomService = RoomService()
    private(set) var memberService = MemberService()
    
    private(set) var room = Room()
    private(set) var memberList = [Member]()
    
    func loadCurrentRoom() {
        let group = DispatchGroup()
        group.enter()
        roomService.getCurrentRoom { roomResult in
            switch roomResult {
            case .failure(let error):
                print(error)
            case .success(let room):
                self.room = room
            }
            group.leave()
        }
    }
    
    func updateRoom(_ room: Room, completion: (() -> Void)? = nil) {
        roomService.updateRoom(room) { error in
            if let error = error {
                print(error)
            } else {
                completion?()
                print("room updated: \(room)")
            }
        }
    }
    
    func roomChangeListener(completion: @escaping (Room) -> Void) {
        roomService.roomChangeListener { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(room):
                self.room = room
                completion(room)
            }
        }
    }
    
    func loadMemberList(completion: @escaping ([Member]) -> Void) {
        memberService.listMembers { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(memberList):
                completion(memberList)
            }
        }
    }
    
    func memberListChangeListener(completion: @escaping ([Member]) -> Void) {
        memberService.membersChangeListener { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(memberList):
                completion(memberList)
            }
        }
    }
}
