//
//  NetworkService.swift
//  AIImage
//
//  Created by Andrew Kochulab on 16.12.2022.
//

import Foundation

enum NetworkRoute {
    case textToImage
    case imageToImage
    case imageToImageInpainting
    case depthToImage
    
    var path: String {
        switch self {
        case .textToImage:
            return "text_to_image"
            
        case .imageToImage:
            return "image_to_image"
            
        case .imageToImageInpainting:
            return "image_to_image_inpainting"
            
        case .depthToImage:
            return "depth_to_image"
        }
    }
}

enum NetworkRequestMethod: String {
    case post = "POST"
    case get = "GET"
    
    var name: String {
        rawValue
    }
}

enum APIVersion: String, CaseIterable {
    case v1, v2
    
    var index: Int {
        switch self {
        case .v1: return 1
        case .v2: return 2
        }
    }
}

protocol NetworkRequest {
    associatedtype Body: Encodable
    
    var route: NetworkRoute { get }
    var method: NetworkRequestMethod { get }
    var body: Body { get }
}

protocol NetworkResponse: Decodable {
    associatedtype Request: NetworkRequest
    
    var request: Request! { get set }
}

final class NetworkService {
    
    // MARK: - Types
    
    typealias ResponseCallback<ResponseContent: NetworkResponse> = (Result<ResponseContent, NetworkError>) -> Void
    
    // MARK: - Properties
    
    static let shared = NetworkService()
    private let serverPath = "http://192.168.0.105:8000"
    
    var apiVersion: APIVersion = .v1
    
    // MARK: - Initialization
    
    private init() { }
    
    // MARK: - Helpers
    
    private func urlRequest(by route: NetworkRoute) -> URLRequest? {
        guard let url = URL(string: "\(serverPath)/\(apiVersion.rawValue)/\(route.path)") else {
            return nil
        }
        
        return URLRequest(url: url)
    }
    
    func processRequest<Request: NetworkRequest, Response: NetworkResponse>(
        _ request: Request,
        completion: @escaping ResponseCallback<Response>
    ) where Response.Request == Request {
        guard var urlRequest = urlRequest(by: request.route) else {
            completion(.failure(.invalidURL))
            return
        }
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = request.method.name
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let bodyData = try? encoder.encode(request.body) {
            urlRequest.httpBody = bodyData
        }
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 3600.0
        sessionConfig.timeoutIntervalForResource = 3600.0
        
        let session = URLSession(configuration: sessionConfig)
        
        DispatchQueue.global(qos: .background).async {
            let task = session.dataTask(with: urlRequest) { data, response, error in
                if error != nil {
                    DispatchQueue.main.async {
                        completion(.failure(.invalidResponse))
                    }
                    
                    return
                }
                
                guard response != nil,
                      let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.invalidResponse))
                    }
                    
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    var response = try decoder.decode(Response.self, from: data)
                    response.request = request
                    
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.invalidResponse))
                    }
                }
            }
            
            task.resume()
        }
    }
}
