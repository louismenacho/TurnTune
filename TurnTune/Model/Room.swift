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
    var turn: Int = 0
    var playingSong: Song?
    var isAwaitingSongSelection: Bool = false
    @ServerTimestamp var dateCreated: Timestamp?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case host
        case turn
        case playingSong
        case isAwaitingSongSelection
        case dateCreated
    }
}
