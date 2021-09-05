//
//  DataAccessError.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/28/21.
//

import Foundation

enum DataAccessError: Error {
    case room(error: Error)
    case member(error: Error)
    case queue(error: Error)
    case player(error: Error)
    case spotifyConfig(error: Error)
}
