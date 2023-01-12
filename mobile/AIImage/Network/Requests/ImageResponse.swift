//
//  ImageResponse.swift
//  AIImage
//
//  Created by Andrew Kochulab on 17.12.2022.
//

import SwiftUI

struct ImageResponse<Request: ImageRequest>: NetworkResponse {
    private enum CodingKeys: String, CodingKey {
        case message
        case images
    }
    
    enum Result {
        case success([UIImage])
        case failure(String)
    }
    
    var request: Request!
    var result: Result
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let message = try? container.decode(String.self, forKey: .message) {
            result = .failure(message)
        } else if let contents = try? container.decode([String].self, forKey: .images) {
            var images = [UIImage]()
            
            for content in contents {
                if let data = Data(base64Encoded: content),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            
            result = .success(images)
        } else {
            result = .failure("Failed")
        }
    }
}
