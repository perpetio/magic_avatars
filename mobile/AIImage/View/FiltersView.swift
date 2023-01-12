//
//  FiltersView.swift
//  AIImage
//
//  Created by Andrew Kochulab on 18.12.2022.
//

import SwiftUI

struct FiltersView: View {
    let title: String
    
    @State var items: [ImageFilter]
    @State var selectedItem: ImageFilter?
    @State var prompt: String = ""
    @State private var showingSheet = false
    
    var willProcess: ((_ item: ImageFilter) -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(Font.system(size: 17).weight(.regular))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .tracking(1)
            
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(items) { item in
                        FilterView(content: item, isSelected: .constant(selectedItem == item))
                            .onTapGesture {
                                if selectedItem != item {
                                    selectedItem = item
                                }
                                
                                if item.isCustom {
                                    showingSheet.toggle()
                                } else {
                                    willProcess?(item)
                                }
                            }
                    }
                }
                .padding(.leading, 12)
                .padding(.trailing, 12)
            }
        }
        .sheet(isPresented: $showingSheet) {
            PromptView(prompt: $prompt, willProcess: { prompt in
                guard selectedItem != nil else { return }
                
                selectedItem!.prompt = prompt
                willProcess?(selectedItem!)
            })
        }
    }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView(
            title: "Avatars",
            items: [
                ImageFilter(id: "2178115195", name: "Moana", imageName: "MoanaFilterIcon", type: .avatar),
                ImageFilter(id: "2178115196", name: "Elsa", imageName: "ElsaFilterIcon", type: .avatar),
                ImageFilter(id: "2178115197", name: "Elena", imageName: "ElenaOfAvalorFilterIcon", type: .avatar)
            ]
        )
    }
}
