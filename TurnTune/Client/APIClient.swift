//
//  APIClient.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/12/21.
//

import Foundation

class APIClient<Endpoint: APIEndpoint> {
    
    func request<Response: Decodable>(_ endpoint: Endpoint, auth: HTTPAuthorization = .none, completion: @escaping (Result<Response, Error>) -> Void) {
        var apiRequest = endpoint.request
        
        apiRequest.auth = auth
        URLSession.shared.dataTask(with: apiRequest.asURLRequest) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(HTTPError.noResponse))
                return
            }

            guard 200...299 ~= response.statusCode else {
                let statusCode = response.statusCode
                let statusDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                let httpError = HTTPError.status(code: statusCode, description: statusDescription)
                self.debug(data: data)
                completion(.failure(httpError))
                return
            }
            
            do {
                self.debug(data: data)
                let responseData = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(responseData))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
    
    func debug(data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            print(String(decoding: jsonData, as: UTF8.self))
        } else {
            print("json data malformed")
        }
    }

}
