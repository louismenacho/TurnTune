//
//  APIEndpoint.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/30/21.
//

import Foundation

struct APIEndpoint {
    var method: HTTPMethod
    var path: String = ""
    var params: [String: String] = [:]
    var headers: [String: String] = [:]
    var body: [String: Any] = [:]
}
