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

extension APIClient {
    func request<Response: Decodable>(_ endpoint: Endpoint, auth: HTTPAuthorization? = nil, completion: ((Result<Response?, ClientError>) -> Void)? = nil) {
        var apiRequest = endpoint.request
        apiRequest.auth = auth ?? self.auth
        
        URLSession.shared.dataTask(with: apiRequest.asURLRequest()) { (data, response, error) in
            if let error = error {
                completion?(.failure(.requestFailed(error)))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                completion?(.failure(.noResponse))
                return
            }
            
            guard 200...299 ~= response.statusCode else {
                let statusCode = response.statusCode
                let statusDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                completion?(.failure(.badResponse(code: statusCode, description: statusDescription)))
                return
            }
            
            if response.statusCode == 204 {
                completion?(.success(nil))
                return
            }
            
            do {
                let responseData = try JSONDecoder().decode(Response.self, from: data)
                completion?(.success(responseData))
            } catch {
                completion?(.failure(.decodingError(error)))
            }
        }
        .resume()
    }
}
