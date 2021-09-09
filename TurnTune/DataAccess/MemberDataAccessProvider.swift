//
//  MemberDataAccessProvider.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/18/21.
//

import Foundation

class MemberDataAccessProvider: DataAccessProvider {
    
    weak var delegate: DataAccessProviderDelegate?
    
    private var currentRoomID: String {
        UserDefaultsRepository().roomID
    }
    
    private var memberRepository: FirestoreRepository<Member> {
        FirestoreRepository<Member>(collectionPath: "rooms/"+currentRoomID+"/members")
    }
    
            
    func addMember(_ member: Member, completion: (() -> Void)? = nil) {
        memberRepository.create(member) { [self] error in
            if let error = error {
                delegate?.dataAccessProvider(self, error: .member(error: error))
            } else {
                completion?()
            }
        }
    }
    
    func removeMember(_ member: Member, completion: (() -> Void)? = nil) {
        memberRepository.delete(member) { [self] error in
            if let error = error {
                delegate?.dataAccessProvider(self, error: .member(error: error))
            } else {
                completion?()
            }
        }
    }
    
    func listMembers(completion: @escaping ([Member]) -> Void) {
        memberRepository.list(memberRepository.collectionReference.order(by: "dateAdded", descending: true)) { [self] result in
            switch result {
            case let .failure(error):
                delegate?.dataAccessProvider(self, error: .member(error: error))
            case let .success(members):
                completion(members)
            }
        }
    }
    
    func membersChangeListener(completion: @escaping ([Member]) -> Void) {
        memberRepository.addListener(memberRepository.collectionReference.order(by: "dateAdded", descending: true)) { [self] result in
            switch result {
            case let .failure(error):
                delegate?.dataAccessProvider(self, error: .member(error: error))
            case let .success(members):
                completion(members)
            }
        }
    }
    
}
