//
//  HTTPError.swift
//  TurnTune
//
//  Created by Louis Menacho on 3/18/21.
//

import Foundation

enum HTTPError: Error {
    case client(error: Error)
    case status(code: Int, description: String)
    case decode(error: Error)
    case noResponse
}
