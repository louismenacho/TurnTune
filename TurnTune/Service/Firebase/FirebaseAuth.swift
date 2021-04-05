//
//  FirebaseAuth.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/19/21.
//

import Foundation
import FirebaseAuth

class FirebaseAuth {
    
    private(set) static var shared = FirebaseAuth()
    
    private init() {}
    
    func signInAnonymously(completion: ((Result<AuthDataResult, Error>) -> Void)? = nil) {
        Auth.auth().signInAnonymously { (authDataResult, error) in
            if let error = error {
                completion?(.failure(error))
            }
            
            if let authData = authDataResult {
                completion?(.success(authData))
            }
        }
    }
    
    func setDisplayName(_ displayName: String, for user: User, completion: ((Error?) -> Void)? = nil) {
        let profile = user.createProfileChangeRequest()
        profile.displayName = displayName
        profile.commitChanges { error in
            completion?(error)
        }
    }
}
