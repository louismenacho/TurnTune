//
//  AppError.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/6/22.
//

import Foundation

enum AppError: Error, LocalizedError {
    case message(_ string: String)
    
    var errorDescription: String? {
        switch self {
        case let .message(string):
            return string
        }
    }
}
