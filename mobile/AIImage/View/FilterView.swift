//
//  FilterView.swift
//  AIImage
//
//  Created by Andrew Kochulab on 18.12.2022.
//

import SwiftUI

struct FilterView: View {
    let content: ImageFilter
    @Binding var isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerSize: .init(width: 37, height: 37))
                    .fill(Color.white)
                    .frame(minWidth: 74, maxWidth: 74, minHeight: 74, maxHeight: 74, alignment: .center)
                    .shadow(color: Color(uiColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.06)), radius: 14, x: 0, y: 8)
                
                if content.type == .background {
                    backgroundImage
                } else {
                    avatarImage
                }
            }
            
            Text(content.name)
                .foregroundColor(Color(red: 0.554, green: 0.612, blue: 0.658))
                .font(isSelected ? Font.custom("SFPro-Regular", size: 14).bold() : Font.custom("SFPro-Regular", size: 14))
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder var avatarImage: some View {
        if content.isCustom {
            Image("CustomAvatarFilterIcon")
                .resizable()
                .frame(minWidth: 32, maxWidth: 32, minHeight: 32, maxHeight: 32, alignment: .center)
                .aspectRatio(contentMode: .fit)
        } else {
            Image(content.imageName)
                .resizable()
                .cornerRadius(37)
                .frame(minWidth: 74, maxWidth: 74, minHeight: 74, maxHeight: 74, alignment: .center)
                .aspectRatio(contentMode: .fit)
        }
    }
    
    @ViewBuilder var backgroundImage: some View {
        if content.isCustom {
            Image("CustomBackgroundFilterIcon")
                .resizable()
                .frame(minWidth: 32, maxWidth: 32, minHeight: 32, maxHeight: 32, alignment: .center)
                .aspectRatio(contentMode: .fit)
        } else {
            Image(content.imageName)
                .resizable()
                .frame(minWidth: 32, maxWidth: 32, minHeight: 32, maxHeight: 32, alignment: .center)
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(
            content: ImageFilter(id: "2178115195", name: "Custom", imageName: "MoanaFilterIcon", isCustom: true, type: .avatar),
            isSelected: .constant(false)
        )
    }
}
