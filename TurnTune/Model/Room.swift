//
//  Room.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/20/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Room: Codable {
    var code: String
    var host: Member
    var playingSong: Song?
    @ServerTimestamp var dateCreated: Timestamp?
}
