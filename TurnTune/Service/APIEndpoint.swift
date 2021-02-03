//
//  APIEndpoint.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/30/21.
//

import Foundation

protocol APIEndpoint {
    var baseURL: URL { get }
    var authorization: APIAuthorization? { get }
    var request: APIRequest { get }
}
