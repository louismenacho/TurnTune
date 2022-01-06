//
//  AppError.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/6/22.
//

import Foundation

enum AppError: Error, LocalizedError {
    case roomLimitReached
    
    var errorDescription: String? {
        switch self {
        case .roomLimitReached:
            return "Room limit reached"
        }
    }
}
