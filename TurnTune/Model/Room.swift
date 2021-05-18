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
    var queueMode: String = "Fair"
    var playingSong: Song?
    @ServerTimestamp var dateCreated: Timestamp?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case host
        case queueMode
        case playingSong
        case dateCreated
    }
}
