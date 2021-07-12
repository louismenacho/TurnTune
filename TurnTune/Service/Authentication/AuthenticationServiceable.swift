//
//  AuthenticationServiceable.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/3/21.
//

import Foundation

protocol AuthenticationServiceable {
    associatedtype User
    
    func signIn(displayName: String, completion: @escaping (Result<User, Error>) -> Void)
    func setDisplayName(_ displayName: String, completion: @escaping (Error?) -> Void)
    func signOut(completion: @escaping (Error?) -> Void)
}
