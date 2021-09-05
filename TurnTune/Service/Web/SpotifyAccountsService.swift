//
//  SpotifyAccountsService.swift
//  TurnTune
//
//  Created by Louis Menacho on 9/5/21.
//

import Foundation

class SpotifyAccountsService {
    
    private var accounts = SpotifyAPIClient<SpotifyAccountsAPI>()
    
    func setClientCredentials(clientID: String, clientSecret: String) {
        accounts.auth = .basic(username: clientID, password: clientSecret)
    }
    
    func generateToken(completion: @escaping (Result<TokenResponse, Error>) -> Void) {
        accounts.request(.apiToken) { result in
            completion(result)
        }
    }
}
