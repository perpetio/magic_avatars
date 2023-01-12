//
//  ImageFilter.swift
//  AIImage
//
//  Created by Andrew Kochulab on 18.12.2022.
//

import Foundation

struct ImageFilter: Identifiable, Hashable {
    enum FilterType: Int {
        case background, avatar, text
    }
    
    let id: String
    let name: String
    let imageName: String
    let isCustom: Bool
    let type: FilterType
    var prompt: String?
    let negativePrompt: String?
    let imageWidth: Int
    let imageHeight: Int
    let strength: Float
    let guidanceScale: Float
    let samplesCount: Int
    let stepsCount: Int
    let seed: Int
    
    init(
        id: String,
        name: String,
        imageName: String,
        isCustom: Bool = false,
        type: FilterType,
        prompt: String? = nil,
        negativePrompt: String? = nil,
        imageWidth: Int = 512,
        imageHeight: Int = 512,
        strength: Float = 0.33,
        guidanceScale: Float = 21.5,
        samplesCount: Int = 1,
        stepsCount: Int = 25,
        seed: Int = 0
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.isCustom = isCustom
        self.type = type
        self.prompt = prompt
        self.negativePrompt = negativePrompt
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.strength = strength
        self.guidanceScale = guidanceScale
        self.samplesCount = samplesCount
        self.stepsCount = stepsCount
        self.seed = seed
    }
}
