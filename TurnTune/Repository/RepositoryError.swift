//
//  RepositoryError.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/31/21.
//

import Foundation

enum RepositoryError: Error {
    case readError(_ error: Error)
    case writeError(_ error: Error)
    case encodingError(_ error: Error)
    case decodingError(_ error: Error)
    case notFound
}
