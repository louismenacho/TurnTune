//
//  SettingsViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/21/21.
//

import Foundation

class SettingsViewModel {
    
    private(set) var authService = FirebaseAuthService()
    private(set) var roomDataAccess = RoomDataAccessProvider()
    private(set) var memberDataAccess = MemberDataAccessProvider()
    
    private(set) var room = Room()
    private(set) var memberList = [Member]()
    
    init() {
        self.roomDataAccess.delegate = self
        self.memberDataAccess.delegate = self
    }
    
    var queueTypes: [QueueType] {
        QueueType.allCases
    }
    
    var currentQueueType: QueueType {
        QueueType(rawValue: room.queueMode) ?? .fair
    }
    
    func loadCurrentRoom() {
        roomDataAccess.getRoom { room in
            self.room = room
        }
    }
    
    func updateRoom(_ room: Room, completion: (() -> Void)? = nil) {
        roomDataAccess.updateRoom(room) {
            completion?()
        }
    }
    
    func roomChangeListener(completion: @escaping (Room) -> Void) {
        roomDataAccess.roomChangeListener { room in
            self.room = room
            completion(room)
        }
    }
    
    func loadMemberList(completion: @escaping ([Member]) -> Void) {
        memberDataAccess.listMembers { memberList in
            self.memberList = memberList
            completion(memberList)
        }
    }
    
    func memberListChangeListener(completion: @escaping ([Member]) -> Void) {
        memberDataAccess.membersChangeListener { memberList in
            self.memberList = memberList
            completion(memberList)
        }
    }
    
    func removeMember(_ member: Member, completion: (() -> Void)? = nil) {
        memberDataAccess.removeMember(member) {
            completion?()
        }
    }
    
    func isHost(_ member: Member) -> Bool {
        return member.userID == room.host.userID
    }
    
    func updateQueueMode(queueType: QueueType) {
        var room = room
        room.queueMode = queueType.rawValue
        updateRoom(room)
    }
}

extension SettingsViewModel: DataAccessProviderDelegate {
    func dataAccessProvider(_ dataAccessProvider: DataAccessProvider, error: DataAccessError) {
        print(error)
    }
}
