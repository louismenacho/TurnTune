//
//  APIAuthorization.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/2/21.
//

import Foundation

enum APIAuthorization {
    case basic(username: String, password: String)
    case bearer(token: String)
}
