//
//  MemberDataAccessProvider.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/18/21.
//

import Foundation

class MemberDataAccessProvider: DataAccessProvider {
    
    weak var delegate: DataAccessProviderDelegate?
    
    private var memberRepository: FirestoreRepository<Member> {
        let roomID = UserDefaultsRepository().roomID
        return FirestoreRepository<Member>(collectionPath: "rooms/"+roomID+"/members")
    }
    
    func getMember(_ userID: String, completion: @escaping (Member?) -> Void) {
        memberRepository.get(id: userID) { [self] result in
            switch result {
                case let .failure(error):
                    if case .notFound = error as? RepositoryError {
                        completion(nil)
                    } else {
                        delegate?.dataAccessProvider(self, error: .member(error: error))
                    }
                case let .success(member):
                    completion(member)
            }
        }
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
    
    func membersChangeListener(completion: @escaping ([Member]) -> Void) {
        memberRepository.addListener(memberRepository.collectionReference.order(by: "dateAdded", descending: false)) { [self] result in
            switch result {
            case let .failure(error):
                delegate?.dataAccessProvider(self, error: .member(error: error))
            case let .success(members):
                completion(members)
            }
        }
    }
    
    func removeListener() {
        memberRepository.removeListener()
    }
    
}
