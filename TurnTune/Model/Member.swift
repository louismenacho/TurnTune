//
//  Member.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/9/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Member {
    var userID: String
    var displayName: String
    
    // MARK: - FirestoreDocument Protocol
    @DocumentID var documentID: String?
    @ServerTimestamp var dateJoined: Timestamp?
    
    init() {
        userID = ""
        displayName = ""
    }
}

extension Member: FirestoreDocument {
    init(userID: String, displayName: String) {
        self.userID = userID
        self.displayName = displayName
        self.documentID = userID
    }
}
