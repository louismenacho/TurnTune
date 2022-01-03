//
//  RoomDetailsViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/28/21.
//

import Foundation

class RoomDetailsViewModel {
    
    var room: Room
    var members = [Member]()
    var memberRepository: FirestoreRepository<Member>
    
    init(_ room: Room) {
        self.room = room
        self.memberRepository = FirestoreRepository<Member>(collectionPath: "rooms/"+room.id+"/members")
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
    
    func removeMembersChangeListener() {
        memberRepository.removeListener()
    }
}
