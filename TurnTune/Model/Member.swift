//
//  Member.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/9/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Member: FireStoreObject {
    @DocumentID var id: String?
    var displayName: String
    @ServerTimestamp var dateJoined: Timestamp?
}

protocol FirestoreDocument: Codable {
    var documentID: String? { get set }
}

struct Object: FirestoreDocument {
    @DocumentID var documentID: String?
}
