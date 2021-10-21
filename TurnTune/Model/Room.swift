//
//  Room.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/20/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Room: FirestoreDocument {
    
    @DocumentID var documentID: String?
    @ServerTimestamp var dateAdded: Timestamp?
    
    var roomID: String
    var host: Member
    var queueMode: String
    var memberCount: Int
    
    init() {
        roomID = ""
        host = Member()
        queueMode = "fair"
        self.memberCount = 0
    }
    
    init(_ roomID: String, host: Member) {
        self.roomID = roomID
        self.host = host
        self.documentID = roomID
        self.queueMode = "fair"
        self.memberCount = 0
    }
}
