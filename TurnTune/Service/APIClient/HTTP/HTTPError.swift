//
//  HTTPError.swift
//  TurnTune
//
//  Created by Louis Menacho on 3/18/21.
//

import Foundation

enum HTTPError: Error {
    case noResponse
    case status(code: Int)
}
