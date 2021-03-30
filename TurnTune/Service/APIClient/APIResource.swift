//
//  APIResource.swift
//  TurnTune
//
//  Created by Louis Menacho on 3/17/21.
//

import Foundation

protocol APIResource {
    var baseURL: URL { get }
    var authorization: HTTPAuthorization { get }
    var endpoint: APIEndpoint { get }
}

extension APIResource {
    
    var request: URLRequest {
        var request = URLRequest(url: requestURL)
        request.httpMethod = requestMethod
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = requestBody
        debug()
        return request
    }
    
    private var requestMethod: String {
        endpoint.method.rawValue
    }
    
    private var requestURL: URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.path.append(endpoint.path)
        components.queryItems = endpoint.params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        return components.url!
    }
    
    private var requestHeaders: [String: String] {
        var headers = endpoint.headers
        
        switch authorization {
        case let .basic(username, password):
            let base64Credentials = (username+":"+password).data(using: .utf8)!.base64EncodedString()
            headers["Authorization"] = "Basic \(base64Credentials)"
        case let .bearer(token):
            headers["Authorization"] = "Bearer \(token)"
        case .none:
            break
        }
        
        return headers
    }
    
    private var requestBody: Data? {
        switch endpoint.headers["Content-Type"] {
        case "application/x-www-form-urlencoded":
            var components = URLComponents()
            components.queryItems = endpoint.body.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            return components.query?.data(using: .utf8)
        default:
            return nil
        }
    }
    
    private func debug() {
        print(requestMethod)
        print(requestURL)
        print(requestHeaders)
        print(String(data: (requestBody ?? "No body".data(using: .utf8)!), encoding: .utf8)!)
    }
}
