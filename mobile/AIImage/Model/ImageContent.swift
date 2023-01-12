//
//  ImageContent.swift
//  AIImage
//
//  Created by Andrew Kochulab on 17.12.2022.
//

import SwiftUI

struct ImageContent: Encodable {
    private enum CodingKeys: String, CodingKey {
        case image
        case prompt
        case negativePrompt = "negative_prompt"
        case imageWidth = "image_width"
        case imageHeight = "image_height"
        case strength
        case guidanceScale = "guidance_scale"
        case samplesCount = "samples_count"
        case stepsCount = "steps_count"
        case seed
    }
    
    let image: String?
    let prompt: String?
    let negativePrompt: String?
    let imageWidth: Int
    let imageHeight: Int
    let strength: Float
    let guidanceScale: Float
    let samplesCount: Int
    let stepsCount: Int
    let seed: Int
    
    init(image: CGImage? = nil, filter: ImageFilter) {
        if let inputImage = image {
            let image = CIImage(cgImage: inputImage)
            let context = CIContext()
            
            if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
               let jpeg = context.jpegRepresentation(of: image, colorSpace: colorSpace) {
                self.image = jpeg.base64EncodedString()
            } else {
                self.image = nil
            }
        } else {
            self.image = nil
        }
        
        self.prompt = filter.prompt
        self.negativePrompt = filter.negativePrompt
        self.imageWidth = filter.imageWidth
        self.imageHeight = filter.imageHeight
        self.strength = filter.strength
        self.guidanceScale = filter.guidanceScale
        self.samplesCount = filter.samplesCount
        self.stepsCount = filter.stepsCount
        self.seed = filter.seed
    }
}
