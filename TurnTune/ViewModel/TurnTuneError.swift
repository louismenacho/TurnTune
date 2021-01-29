//
//  TurnTuneError.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/19/20.
//  Copyright © 2020 Louis Menacho. All rights reserved.
//

import Foundation

enum TurnTuneError: Error {
    case invalidRoomCode
    case unauthorized
}

extension TurnTuneError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .invalidRoomCode:
            return "Invalid Room Code"
        case .unauthorized:
            return "Unauthorized"
        }
    }
}
