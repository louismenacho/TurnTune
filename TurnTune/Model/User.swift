//
//  User.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/27/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: FirestoreDocument {
    @DocumentID var documentID: String?
    @ServerTimestamp var dateAdded: Timestamp?
    var displayName: String = ""
}
