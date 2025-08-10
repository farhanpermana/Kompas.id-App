//
//  APIService.swift
//  Kompas.id
//
//  Created by Farhan on 05/08/25.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL was invalid."
        case .noData:
            return "No data was received from the server."
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "Server responded with status code \(statusCode)."
        }
    }
}

protocol APIServiceProtocol {
    func fetchData<T: Decodable>(from urlString: String, completion: @escaping (Result<T, APIError>) -> Void)
}

class APIService: APIServiceProtocol {
    static let shared = APIService()
    
    private init() {}
    
    func fetchData<T: Decodable>(from urlString: String, completion: @escaping (Result<T, APIError>) -> Void) {
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(APIError.invalidURL))
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(APIError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    completion(.failure(APIError.httpError(statusCode)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.noData))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(APIError.decodingError(error)))
                }
            }
        }.resume()
    }
}
