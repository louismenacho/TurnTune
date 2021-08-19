//
//  MemberService.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/18/21.
//

import Foundation

class MemberService {
    
    private var memberRepository: FirestoreRepository<Member> {
        FirestoreRepository<Member>(collectionPath: "rooms/"+currentRoomID+"/members")
    }
    
    private var currentRoomID: String {
        UserDefaultsRepository().roomID
    }
        
    func addMember(_ member: Member, completion: @escaping (Error?) -> Void) {
        memberRepository.create(member) { error in
            completion(error)
        }
    }
    
    func removeMember(_ member: Member, completion: @escaping (Error?) -> Void) {
        memberRepository.delete(member) { error in
            completion(error)
        }
    }
    
    func listMembers(completion: @escaping (Result<[Member], Error>) -> Void) {
        memberRepository.list(memberRepository.collectionReference.order(by: "dateJoined", descending: true)) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(members):
                completion(.success(members))
            }
        }
    }
    
    func membersChangeListener(completion: @escaping (Result<[Member], Error>) -> Void) {
        memberRepository.addListener(memberRepository.collectionReference.order(by: "dateJoined", descending: true)) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(members):
                completion(.success(members))
            }
        }
    }
    
}
