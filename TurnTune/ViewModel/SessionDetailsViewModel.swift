//
//  SessionDetailsViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/28/21.
//

import Foundation

class SessionDetailsViewModel {
    
    var session: Session
    var members = [Member]()
    var memberRepository: FirestoreRepository<Member>
    
    init(_ session: Session) {
        self.session = session
        self.memberRepository = FirestoreRepository<Member>(collectionPath: "sessions/"+session.id+"/members")
    }
    
    func membersChangeListener(completion: @escaping (Result<Void, RepositoryError>) -> Void) {
        let query = memberRepository.collectionReference.order(by: "dateAdded")
        memberRepository.addListener(query) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(members):
                self.members = members
                completion(.success(()))
            }
        }
    }
}
