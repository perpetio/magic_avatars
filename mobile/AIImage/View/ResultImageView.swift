//
//  ResultImageView.swift
//  AIImage
//
//  Created by Andrew Kochulab on 18.12.2022.
//

import SwiftUI

struct ResultImageView: View {
    @Binding var image: UIImage
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .background(Color.white)
    }
}

struct ResultImageView_Previews: PreviewProvider {
    static var previews: some View {
        ResultImageView(image: .constant(UIImage(named: "MoanaFilterIcon")!))
    }
}

