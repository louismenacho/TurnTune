//
//  SpotifyConfig.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/12/21.
//

import Foundation
import FirebaseFirestore

struct SpotifyConfig: FirestoreDocument {
    
    var documentID: String?
    var dateAdded: Timestamp?
    
    var clientID: String
    var clientSecret: String
    var redirectURL: String
    var tokenSwapURL: String
    var tokenRefreshURL: String
}
