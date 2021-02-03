//
//  APIService.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/29/21.
//

import Foundation

class APIService<EndpointType: APIEndpoint> {
    
    func request(_ endpoint: EndpointType, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let request = try buildURLRequest(from: endpoint)
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(error!))
                    return
                }
                
//                print(String(data: data, encoding: .utf8)!)

                guard 200...299 ~= (response as! HTTPURLResponse).statusCode else {
//                    completion(.failure(error!))
                    return
                }

                completion(.success(data))
            }
            .resume()
        } catch {
            completion(.failure(error))
        }
    }

    func buildURLRequest(from endpoint: EndpointType) throws -> URLRequest {
        var request = URLRequest(url: buildURL(from: endpoint))
        request.httpMethod = endpoint.request.method.rawValue
        request.allHTTPHeaderFields = endpoint.request.headers
        request.httpBody = encodeBody(from: endpoint)
    
        switch endpoint.authorization {
        case let .basic(username, password):
            let base64Credentials = (username+":"+password).data(using: .utf8)!.base64EncodedString()
            request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        case let .bearer(token):
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        case .none:
            break
        }
        
        return request
    }
    
    func buildURL(from endpoint: EndpointType) -> URL {
        var components = URLComponents(url: endpoint.baseURL, resolvingAgainstBaseURL: false)!
        components.path.append(endpoint.request.path)
        components.queryItems = endpoint.request.query.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        return components.url!
    }
    
    func encodeBody(from endpoint: EndpointType) -> Data? {
        switch endpoint.request.headers["Content-Type"] {
        case "application/x-www-form-urlencoded":
            var components = URLComponents()
            components.queryItems = endpoint.request.body.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            return components.query?.data(using: .utf8)
        default:
            return nil
        }
    }
}
