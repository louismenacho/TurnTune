//
//  ViewModelError.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/19/20.
//  Copyright © 2020 Louis Menacho. All rights reserved.
//

import Foundation

enum ViewModelError: Error {
    case home(error: Error)
    case player(error: Error)
    case search(error: Error)
    case setting(error: Error)
}

extension ViewModelError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case let .home(error):
                return error.localizedDescription
            case let .player(error):
                return error.localizedDescription
            case let .search(error):
                return error.localizedDescription
            case let .setting(error):
                return error.localizedDescription
        }
    }
}
