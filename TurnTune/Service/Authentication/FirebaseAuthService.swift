//
//  FirebaseAuthService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/9/21.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService: AuthenticationServiceable {
    
    private(set) var auth: Auth = {
        Auth.auth()
    }()
    
    var isSignedIn: Bool {
        auth.currentUser != nil
    }
    
    var currentUser: Member {
        Member(
            userID: UserDefaultsRepository().userID,
            displayName: UserDefaultsRepository().displayName
        )
    }
        
    func signIn(completion: @escaping (Error?) -> Void) {
        auth.signInAnonymously { authDataResult, error in
            if let authData = authDataResult {
                UserDefaultsRepository().userID = authData.user.uid
            }
            completion(error)
        }
    }
    
    func setDisplayName(_ displayName: String, completion: @escaping (Error?) -> Void) {
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges { error in
            if error == nil {
                UserDefaultsRepository().displayName = displayName
            }
            completion(error)
        }
    }
    
    func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try auth.signOut()
        } catch {
            completion(error)
        }
    }
    
    func addStateDidChangeListener(completion: @escaping (Result<Auth, Error>) -> Void) {
        auth.addStateDidChangeListener { auth, user in
            completion(.success(auth))
        }
    }

}
