//
//  QueueItem.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/23/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct QueueItem: FirestoreDocument {
    
    @DocumentID var documentID: String?
    @ServerTimestamp var dateAdded: Timestamp?
    
    var song: Song = Song()
    var priority: Int = 0
    var didPlay: Bool = false
    var addedBy: Member = Member()
    
}
