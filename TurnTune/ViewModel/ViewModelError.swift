//
//  ViewModelError.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/19/20.
//  Copyright © 2020 Louis Menacho. All rights reserved.
//

import Foundation

enum ViewModelError: Error {
    case httpError(error: HTTPError)
    case repositoryError(error: RepositoryError)
    case dataAccessError(error: DataAccessError)
    case musicPlayerError(error: MusicPlayerError)
    case musicBrowserError(error: MusicBrowserError)
    case authenticationError(error: AuthenticationError)
    case roomIsFull
    case roomNotFound
}

extension ViewModelError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case let .httpError(error):
                return error.localizedDescription
            case let .repositoryError(error):
                return error.localizedDescription
            case let .dataAccessError(error):
                return error.localizedDescription
            case let .musicPlayerError(error):
                return error.localizedDescription
            case let .musicBrowserError(error):
                return error.localizedDescription
            case let .authenticationError(error):
                return error.localizedDescription
            case .roomIsFull:
                return "Room is full"
            case .roomNotFound:
                return "Room does not exist"
        }
    }
}
