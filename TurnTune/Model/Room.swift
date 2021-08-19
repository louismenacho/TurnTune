//
//  Room.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/20/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Room {
    var roomID: String
    var host: Member
    var queueType: String
    
    // MARK: - FirestoreDocument Protocol
    @DocumentID var documentID: String?
    @ServerTimestamp var dateCreated: Timestamp?
    
    init() {
        roomID = ""
        host = Member()
        queueType = "fair"
    }
}

extension Room: FirestoreDocument {
    init(_ roomID: String, host: Member) {
        self.roomID = roomID
        self.host = host
        self.documentID = roomID
        self.queueType = "fair"
    }
}
