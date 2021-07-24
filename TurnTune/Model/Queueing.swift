//
//  Queueing.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/24/21.
//

import Foundation

protocol Queueing {
    var orderGroup: Int { get set }
    var didPlay: Bool { get set }
    var addedBy: Member { get set }
}
