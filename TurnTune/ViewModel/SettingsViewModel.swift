//
//  SettingsViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/21/21.
//

import Foundation

class SettingsViewModel {
    
    private(set) var authService = FirebaseAuthService()
    
    private(set) var roomDataAccess: RoomDataAccessProvider
    private(set) var memberDataAccess: MemberDataAccessProvider
    
    private(set) var room = Room()
    private(set) var memberList = [Member]()
    
    init(roomDataAccess: RoomDataAccessProvider, memberDataAccess: MemberDataAccessProvider) {
        self.roomDataAccess = roomDataAccess
        self.memberDataAccess = memberDataAccess
        self.roomDataAccess.delegate = self
        self.memberDataAccess.delegate = self
    }
    
    var queueTypes: [QueueType] {
        QueueType.allCases
    }
    
    var currentQueueType: QueueType {
        QueueType(rawValue: room.queueMode) ?? .fair
    }
    
    var currentMember: Member? {
        memberList.first { $0.userID == authService.currentUserID }
    }
    
    var currentMemberPosition: Int? {
        memberList.firstIndex { $0.userID == authService.currentUserID }
    }
    
    var isCurrentMemberHost: Bool {
        authService.currentUserID == room.host.userID
    }
    
    func roomChangeListener(completion: @escaping (Room) -> Void) {
        roomDataAccess.roomChangeListener { room in
            self.room = room
            completion(room)
        }
    }
    
    func memberListChangeListener(completion: @escaping ([Member]?) -> Void) {
        memberDataAccess.membersChangeListener { [self] memberList in
            self.memberList = memberList
            print("memberListChangeListener memberlist: \(memberList.map { $0.displayName })")
            if memberList.first(where: { $0.userID == self.authService.currentUserID }) != nil {
                completion(memberList)
            } else {
                completion(nil)
            }
        }
    }
    
    func removeAllListeners() {
        roomDataAccess.removeListener()
        memberDataAccess.removeListener()
    }
        
    // MARK: - Host Methods
    
    func updateRoom(_ room: Room, completion: (() -> Void)? = nil) {
        roomDataAccess.updateRoom(room) {
            completion?()
        }
    }
    
    func removeMember(_ member: Member, completion: (() -> Void)? = nil) {
        memberDataAccess.removeMember(member) {
            completion?()
        }
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
