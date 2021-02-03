//
//  Song.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/19/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Song: Codable {
    var id: String
    var name: String
    var artistName: String
    var artworkURL: String?
    var durationInMillis: Int
    var addedBy: Member?
}
