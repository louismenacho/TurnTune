//
//  SettingsViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/21/21.
//

import Foundation

class SettingsViewModel {
    
    private(set) var authService = FirebaseAuthService()
    private(set) var roomService = RoomDataAccessProvider()
    private(set) var memberService = MemberDataAccessProvider()
    
    private(set) var room = Room()
    private(set) var memberList = [Member]()
    
    var queueTypes: [QueueType] {
        QueueType.allCases
    }
    
    var currentQueueType: QueueType {
        QueueType(rawValue: room.queueMode) ?? .fair
    }
    
    func loadCurrentRoom() {
        roomService.getRoom { room in
            self.room = room
        }
    }
    
    func updateRoom(_ room: Room, completion: (() -> Void)? = nil) {
        roomService.updateRoom(room) {
            completion?()
        }
    }
    
    func roomChangeListener(completion: @escaping (Room) -> Void) {
        roomService.roomChangeListener { room in
            self.room = room
            completion(room)
        }
    }
    
    func loadMemberList(completion: @escaping ([Member]) -> Void) {
        memberService.listMembers { memberList in
            self.memberList = memberList
            completion(memberList)
        }
    }
    
    func memberListChangeListener(completion: @escaping ([Member]) -> Void) {
        memberService.membersChangeListener { memberList in
            self.memberList = memberList
            completion(memberList)
            
        }
    }
    
    func removeMember(_ member: Member, completion: (() -> Void)? = nil) {
        memberService.removeMember(member) {
            completion?()
        }
    }
    
    func isHost(_ member: Member) -> Bool {
        return member.userID == room.host.userID
    }
}
