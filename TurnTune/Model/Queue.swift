//
//  Queue.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/25/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Queue: Codable {
    var owner: Member
    var songs: [Song]
    @ServerTimestamp var dateUpdated: Timestamp?
}
