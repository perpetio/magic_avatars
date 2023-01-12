//
//  NetworkError.swift
//  AIImage
//
//  Created by Andrew Kochulab on 16.12.2022.
//

import Foundation

enum NetworkError: String, LocalizedError {
    case invalidURL = "Received invalid URL"
    case invalidResponse = "Received invalid response"
    
    var errorDescription: String? {
        rawValue
    }
}
