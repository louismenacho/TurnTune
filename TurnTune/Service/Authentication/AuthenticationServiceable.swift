//
//  AuthenticationServiceable.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/3/21.
//

import Foundation

protocol AuthenticationServiceableDelegate: AnyObject {
    func authenticationServiceable(_ authenticationServiceable: AuthenticationServiceable, error: AuthenticationError)
}

protocol AuthenticationServiceable {
    
    var delegate: AuthenticationServiceableDelegate? { get }
    
    var currentUserID: String { get }
    var isSignedIn: Bool { get }
    
    func signIn(completion: (() -> Void)?)
    func signOut(completion: (() -> Void)?)
}
