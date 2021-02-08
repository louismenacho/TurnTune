//
//  TokenResponse.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/29/21.
//

import Foundation

struct TokenResponse: Codable {
    var accessToken: String
    var tokenType: String
    var expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
