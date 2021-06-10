//
//  MemberListViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/1/21.
//

import Foundation

class MemberListViewModel: RepoViewModel {
    
    private(set) var memberRepository: FirestoreRepository<Member>
    
    private(set) var memberList = [Member]()
    
    required init(repository: FirestoreRepository<Member>) {
        memberRepository = repository
    }
    
    func loadMemberList(completion: @escaping (Result<[Member], Error>) -> Void) {
        memberRepository.list(memberRepository.collectionReference.order(by: "dateJoined")) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(memberList):
                self.memberList = memberList
                completion(.success(memberList))
            }
        }
    }
    
    func registerMemberListListener(completion: @escaping (Result<[Member], Error>) -> Void) {
        memberRepository.addListener(memberRepository.collectionReference.order(by: "dateJoined")) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(memberList):
                self.memberList = memberList
                completion(.success(memberList))
            }
        }
    }
}
