//
//  AuthService.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/19/21.
//

import Foundation
import FirebaseAuth

class AuthService {
    
    private var auth = Auth.auth()
    
    func signIn(displayName: String, completion: ((User) -> Void)? = nil) {
        auth.signInAnonymously { (authDataResullt, error) in
            guard let authData = authDataResullt else {
                print("Firebase authentication failed")
                return
            }
            let profileChange = authData.user.createProfileChangeRequest()
            profileChange.displayName = displayName
            profileChange.commitChanges { error in completion?(authData.user) }
        }
    }
}
