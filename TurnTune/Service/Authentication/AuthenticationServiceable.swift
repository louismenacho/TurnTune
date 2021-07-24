//
//  AuthenticationServiceable.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/3/21.
//

import Foundation

protocol AuthenticationServiceable {
    
    var isSignedIn: Bool { get }
    var currentUser: Member { get }
    
    func signIn(completion: @escaping (Error?) -> Void)
    func setDisplayName(_ displayName: String, completion: @escaping (Error?) -> Void)
    func signOut(completion: @escaping (Error?) -> Void)
}
