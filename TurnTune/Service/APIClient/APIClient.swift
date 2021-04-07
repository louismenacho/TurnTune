//
//  APIClient.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/29/21.
//

import Foundation

class APIClient<Resource: APIResource> {
    
    func request<T: Decodable>(_ resource: Resource, responseType: T.Type = T.self, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: resource.request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(HTTPError.noResponse))
                return
            }

            guard 200...299 ~= response.statusCode else {
                completion(.failure(HTTPError.status(code: response.statusCode)))
                return
            }
            
            do {
//                self.debug(data: data)
                let object = try JSONDecoder().decode(T.self, from: data)
                completion(.success(object))
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
