//
//  Room.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/20/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Room: FireStoreObject {
    @DocumentID var id: String? = ""
    var hostId: String
    var queueMode: String = "Fair"
    var playerState = PlayerState()
    @ServerTimestamp var dateCreated: Timestamp?
}
