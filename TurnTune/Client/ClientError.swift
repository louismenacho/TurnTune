//
//  ClientError.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/18/21.
//

import Foundation

enum ClientError: Error {
    case requestFailed(_ error: Error)
    case badResponse(code: Int, description: String)
    case decodingError(_ error: Error)
    case noResponse
}
