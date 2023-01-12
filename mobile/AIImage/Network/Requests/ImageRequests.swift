//
//  ImageRequests.swift
//  AIImage
//
//  Created by Andrew Kochulab on 20.12.2022.
//

import Foundation

class ImageRequest: NetworkRequest {
    let body: ImageContent
    var route: NetworkRoute { fatalError() }
    var method: NetworkRequestMethod { .post }
    
    required init(body: ImageContent) {
        self.body = body
    }
}

final class TextToImageRequest: ImageRequest {
    override var route: NetworkRoute { .textToImage }
}

final class ImageToImageRequest: ImageRequest {
    override var route: NetworkRoute { .imageToImage }
}

final class ImageToImageInpaintingRequest: ImageRequest {
    override var route: NetworkRoute { .imageToImageInpainting }
}

final class DepthToImageRequest: ImageRequest {
    override var route: NetworkRoute { .depthToImage }
}

typealias TextToImageResponse = ImageResponse<TextToImageRequest>
typealias ImageToImageResponse = ImageResponse<ImageToImageRequest>
typealias ImageToImageInpaintingResponse = ImageResponse<ImageToImageInpaintingRequest>
typealias DepthToImageResponse = ImageResponse<DepthToImageRequest>
