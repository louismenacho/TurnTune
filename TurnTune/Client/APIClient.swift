//
//  APIClient.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/12/21.
//

import Foundation

protocol APIClient {
    associatedtype Endpoint: APIEndpoint
    var auth: HTTPAuthorization { get set }
}

extension APIClient {
    func request<Response: Decodable>(_ endpoint: Endpoint, auth: HTTPAuthorization? = nil, completion: ((Result<Response, HTTPError>) -> Void)? = nil, emptyCompletion: ((Result<Void, HTTPError>) -> Void)? = nil) {
        var apiRequest = endpoint.request
        apiRequest.auth = auth ?? self.auth
        
        URLSession.shared.dataTask(with: apiRequest.asURLRequest) { (data, response, error) in
            if let error = error {
                completion?(.failure(.client(error: error)))
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                completion?(.failure(HTTPError.noResponse))
                return
            }
    
            guard 200...299 ~= response.statusCode else {
                let statusCode = response.statusCode
                let statusDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                let httpError = HTTPError.status(code: statusCode, description: statusDescription)
                debug(apiRequest.asURLRequest)
                debug(data)
                completion?(.failure(httpError))
                return
            }
            
            do {
                if response.statusCode == 204 {
                    emptyCompletion?(.success(()))
                } else {
                    let responseData = try JSONDecoder().decode(Response.self, from: data)
                    completion?(.success(responseData))
                }
            } catch {
                completion?(.failure(.decode(error: error)))
            }
        }
        .resume()
    }
    
    func debug(_ request: URLRequest) {
        print("APIClient request:")
        print(request.httpMethod ?? "no http method")
        print(request.url ?? "no URL")
        print(request.allHTTPHeaderFields ?? "no Headers")
        if let body = request.httpBody {
            print(String(data: body, encoding: .utf8) ?? "stringify body data failed")
        }
    }
    
    func debug(_ data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            print(String(decoding: jsonData, as: UTF8.self))
        } else {
            print("json data malformed")
        }
    }

}
