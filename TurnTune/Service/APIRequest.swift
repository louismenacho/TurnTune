//
//  APIRequest.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/31/21.
//

import Foundation

struct APIRequest {
    enum HTTPMethod: String {
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
    }
    
    var method: HTTPMethod
    var path: String
    var query: [String: String] = [:]
    var headers: [String: String] = [:]
    var body: [String: Any] = [:]
}
