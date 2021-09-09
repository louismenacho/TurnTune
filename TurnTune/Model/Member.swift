//
//  Member.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/9/20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Member: FirestoreDocument {
    
    @DocumentID var documentID: String?
    @ServerTimestamp var dateAdded: Timestamp?
    
    var userID: String
    var displayName: String

    init() {
        userID = ""
        displayName = ""
    }
    
    init(userID: String, displayName: String) {
        self.userID = userID
        self.displayName = displayName
        self.documentID = userID
    }
}
