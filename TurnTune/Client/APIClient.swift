//
//  APIClient.swift
//  TurnTune
//
//  Created by Louis Menacho on 12/17/21.
//

import Foundation

protocol APIClient {
    associatedtype Endpoint: APIEndpoint
    var auth: HTTPAuthorization { get set }
}
