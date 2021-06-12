//
//  FirebaseAuthService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/9/21.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService: AuthenticationService {
    
    private(set) var auth = Auth.auth()
    
    func signIn(displayName: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signInAnonymously { [self] (authDataResult, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let authData = authDataResult {
                setDisplayName(displayName) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(authData.user))
                    }
                }
            }
        }
    }
    
    func setDisplayName(_ displayName: String, completion: @escaping (Error?) -> Void) {
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges { error in
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
    
    func isSignedIn() -> Bool {
        auth.currentUser != nil
    }
    
    func currentUser() -> User? {
        auth.currentUser
    }
    
    private func isNameValid(name: String) -> Bool {
        if name.isEmpty || name.count > 12 {
            print("Invalid name")
            return false
        }
        return true
    }
    
}
