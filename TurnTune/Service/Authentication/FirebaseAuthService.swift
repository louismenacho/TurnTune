//
//  FirebaseAuthService.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/9/21.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService: AuthenticationServiceable {
    
    weak var delegate: AuthenticationServiceableDelegate?
    
    var currentUserID: String = UserDefaultsRepository().userID {
        didSet {
            UserDefaultsRepository().userID = currentUserID
        }
    }
    
    private var auth: Auth = {
        Auth.auth()
    }()
    
    var isSignedIn: Bool {
        auth.currentUser != nil
    }
        
    func signIn(completion: (() -> Void)?) {
        auth.signInAnonymously { [self] authDataResult, error in
            if let error = error {
                delegate?.authenticationServiceable(self, error: .signInFailed(error: error))
            }
            if let authData = authDataResult {
                self.currentUserID = authData.user.uid
                completion?()
            }
        }
    }
    
    func signOut(completion: (() -> Void)?) {
        do {
            try auth.signOut()
        } catch {
            delegate?.authenticationServiceable(self, error: .signOutFailed(error: error))
        }
    }
    
    func addStateDidChangeListener(completion: @escaping (Auth) -> Void) {
        auth.addStateDidChangeListener { auth, user in
            completion(auth)
        }
    }

}
