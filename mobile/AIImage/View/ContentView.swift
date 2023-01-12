//
//  ContentView.swift
//  AIImage
//
//  Created by Andrew Kochulab on 16.12.2022.
//

import SwiftUI
import TTProgressHUD

struct ContentView: View {
    @State private var image: CGImage?
    @State private var backgroundFilters = [ImageFilter]()
    @State private var avatarFilters = [ImageFilter]()
    
    @State private var hudVisible = false
    @State private var hudConfig = TTProgressHUDConfig(
        minSize: CGSize(width: 40, height: 40),
        imageViewSize: CGSize(width: 40, height: 40)
    )
    
    var body: some View {
        NavigationView {
            if hudVisible {
                loadingView
            } else {
                contentView
            }
        }
        .toolbar(.hidden, for: .automatic)
        .onAppear(perform: getFilters)
    }
    
    @ViewBuilder private var loadingView: some View {
        TTProgressHUD($hudVisible, config: hudConfig)
    }
    
    @ViewBuilder private var contentView: some View {
        VStack(spacing: 12) {
            ImageView(selectedImage: $image) { prompt in
                performTextToImage(prompt: prompt)
            }
            .frame(height: 400)
            
            VStack {
                VStack(spacing: 16) {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 10)
                    
                    FiltersView(title: "Background Filters", items: backgroundFilters) { filter in
                        performImageToImageInpainting(filter: filter)
                    }
                    
                    FiltersView(title: "Avatar Filters", items: avatarFilters) { filter in
                        performImageToImage(filter: filter)
                    }
                }
                
                Spacer()
            }
            .background(Color(red: 0.942, green: 0.955, blue: 0.967))
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    func getFilters() {
        backgroundFilters = [
            ImageFilter(id: "Sea_1", name: "Sea", imageName: "SeaFilterIcon", type: .background, prompt: "masterpiece, best quality,, bestquality,Amazing,beautiful detailed eyes,1boy,1chibi,bird wings,finely detail,Depth of field,extremelydetailed CG unity 8k wallpaper,masterpiece, full body,(vtuberminato aqua),green hair and black hair, blu overcoat, centre parting, art book, trees and sea in the back grand ,red eyes, smile, circular eyebrow,fox ears, I really want to stay at your house, Yoji Shinkawa", negativePrompt: "", strength: 0.4, guidanceScale: 11, samplesCount: 1, stepsCount: 46, seed: 3282961398),
            
            ImageFilter(id: "Sky_1", name: "Sky", imageName: "SkyFilterIcon", type: .background, prompt: "futuristic lighthouse, flash light, hyper realistic, epic composition, cinematic, landscape vista photography, landscape veduta photo & tdraw, detailed landscape painting rendered in enscape, miyazaki, 4k detailed post processing, unreal engineered", negativePrompt: "", strength: 0.6, guidanceScale: 5, samplesCount: 1, stepsCount: 25, seed: 873468579),
            
            ImageFilter(id: "Sun_1", name: "Sun", imageName: "SunFilterIcon", type: .background, prompt: "by peter mohrbacher,  hdr, Sunsets, artstation, 4k 3d, by wayne barlowe,  rossdraws global illumination, terragen, hyper detailed, Animal T-Shirt Design, art by atey ghailan, battle field, epic, art by craig mullins, full hd, by craig mullins, Anime / Manga", negativePrompt: "", strength: 0.5, guidanceScale: 12, samplesCount: 1, stepsCount: 20, seed: 0),
            
            ImageFilter(id: "Custom", name: "Custom", imageName: "", isCustom: true, type: .background, negativePrompt: "", strength: 0.4, guidanceScale: 10, samplesCount: 1, stepsCount: 40, seed: 0)
        ]
        
        avatarFilters = [
            ImageFilter(id: "Moana_1", name: "Moana", imageName: "MoanaFilterIcon", type: .avatar, prompt: "Moana, d & d, fantasy, intricate, elegant, highly detailed, digital painting, artstation, concept art, matte, sharp focus, illustration, hearthstone, art by artgerm and greg rutkowski and alphonse mucha, hdr 4k, 8k", negativePrompt: "", strength: 0.3, guidanceScale: 21, samplesCount: 1, stepsCount: 100, seed: 2337194060),
            
            ImageFilter(id: "Elsa_1", name: "Elsa", imageName: "ElsaFilterIcon", type: .avatar, prompt: "Elsa, d & d, fantasy, intricate, elegant, highly detailed, digital painting, artstation, concept art, matte, sharp focus, illustration, hearthstone, art by artgerm and greg rutkowski and alphonse mucha, hdr 4k, 8k", negativePrompt: "", strength: 0.4, guidanceScale: 21, samplesCount: 1, stepsCount: 100, seed: 2337194060),
            
            ImageFilter(id: "Elena_1", name: "Elena", imageName: "ElenaOfAvalorFilterIcon", type: .avatar, prompt: "pixar movie still portrait photo of madison beer, jessica alba : : woman : : as hero catgirl cyborg woman by pixar : : by greg rutkowski, wlop, rossdraws, artgerm, weta, marvel, rave girl, leeloo, unreal engine, glossy skin, pearlescent, wet, bright morning, anime, sci - fi, maxim magazine cover, : :", negativePrompt: "", strength: 0.6, guidanceScale: 18, samplesCount: 1, stepsCount: 60, seed: 4127056100),
            
            ImageFilter(id: "Custom", name: "Custom", imageName: "", isCustom: true, type: .avatar, negativePrompt: "", strength: 0.6, guidanceScale: 8, samplesCount: 1, stepsCount: 80, seed: 0)
        ]
    }
    
    private func performImageGeneration<Request: ImageRequest>(_ request: Request) {
        hudVisible = true
        
        NetworkService.shared.processRequest(request) { (result: Result<ImageResponse<Request>, NetworkError>) in
            hudVisible = false
            
            switch result {
            case .success(let response):
                switch response.result {
                case .success(let images):
                    self.image = images.first?.cgImage
                    
                case .failure(_):
                    break
                }
                
            case .failure(_):
                break
            }
        }
    }
    
    func performTextToImage(prompt: String) {
        let filter = ImageFilter(id: "0", name: "", imageName: "", type: .text, prompt: prompt)
        let content = ImageContent(filter: filter)
        performImageGeneration(TextToImageRequest(body: content))
    }
    
    func performImageToImageInpainting(filter: ImageFilter) {
        perform(using: filter, requestType: ImageToImageInpaintingRequest.self)
    }
    
    func performImageToImage(filter: ImageFilter) {
        perform(using: filter, requestType: ImageToImageRequest.self)
    }
    
    func performDepthToImage(filter: ImageFilter) {
        perform(using: filter, requestType: DepthToImageRequest.self)
    }
    
    private func perform(using filter: ImageFilter, requestType: ImageRequest.Type) {
        guard let image = image else { return }
        
        let content = ImageContent(image: image, filter: filter)
        performImageGeneration(requestType.init(body: content))
    }
}
