//
//  Member.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/9/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Member: Codable {
    var uid: String
    var displayName: String
    var selectedSong: Song?
    @ServerTimestamp var dateJoined: Timestamp?
}
