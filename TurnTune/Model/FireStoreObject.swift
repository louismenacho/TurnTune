//
//  FireStoreObject.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/31/21.
//

import Foundation

protocol FireStoreObject: Codable {
    var id: String? { get set }
}
