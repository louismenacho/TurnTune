//
//  AuthenticationError.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/29/21.
//

import Foundation

enum AuthenticationError: Error {
    case signInFailed(error: Error)
    case signOutFailed(error: Error)
}

extension AuthenticationError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .signInFailed:
                return "Sign in failed"
            case .signOutFailed:
                return "Sign out failed"
        }
    }
}
