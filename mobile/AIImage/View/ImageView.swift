//
//  ImageView.swift
//  AIImage
//
//  Created by Andrew Kochulab on 16.12.2022.
//

import SwiftUI

struct ImageView: View {
    @Binding var selectedImage: CGImage?
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isImagePickerDisplay = false
    
    @State var prompt: String = ""
    @State private var isPromptPopupDisplay = false
    var willGenerateImage: ((_ prompt: String) -> Void)?
    
    var body: some View {
        VStack {
            VStack {
                if let image = selectedImage {
                    Image(image, scale: 1.0, label: Text(""))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerSize: .init(width: 16, height: 16)))
                } else {
                    RoundedRectangle(cornerSize: .init(width: 16, height: 16), style: .continuous)
                        .fill(Color(red: 0.942, green: 0.955, blue: 0.967))
                }
            }
            .padding(.top)
            .padding(.leading)
            .padding(.trailing)
            
            HStack(alignment: .center, spacing: 16) {
                Button {
                    sourceType = .camera
                    isImagePickerDisplay.toggle()
                } label: {
                    Image("cameraIcon")
                        .font(.system(size: 50))
                }
                
                Button {
                    sourceType = .photoLibrary
                    isImagePickerDisplay.toggle()
                } label: {
                    Image("libraryIcon")
                        .font(.system(size: 56))
                }
                
                Button {
                    isPromptPopupDisplay = true
                } label: {
                    Image("promptIcon")
                        .font(.system(size: 50))
                }
            }.padding()
        }
        .sheet(isPresented: $isImagePickerDisplay) {
            ImagePickerView(
                selectedImage: $selectedImage,
                sourceType: sourceType
            )
        }
        .sheet(isPresented: $isPromptPopupDisplay) {
            PromptView(prompt: $prompt, willProcess: { prompt in
                willGenerateImage?(prompt)
            })
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(selectedImage: .constant(nil))
    }
}
