//
//  FirestoreDocument.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/31/21.
//

import Foundation

protocol FirestoreDocument: Codable {
    var documentID: String? { get set }
}
