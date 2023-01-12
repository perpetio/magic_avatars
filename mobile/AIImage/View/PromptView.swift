//
//  PromptView.swift
//  AIImage
//
//  Created by Andrew Kochulab on 18.12.2022.
//

import SwiftUI

struct PromptView: View {
    @Binding var prompt: String
    @Environment(\.dismiss) var dismiss
    var willProcess: ((_ prompt: String) -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Enter your expectations:")
                .font(Font.system(size: 17).weight(.regular))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                .tracking(1)
            
            TextField("Text", text: $prompt)
                .padding()
                .font(.body)
                .background(.bar)
                .cornerRadius(12)
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
            
            Button("Submit") {
                dismiss()
                willProcess?(prompt)
            }
            .font(.body)
            .padding()
            .background(Color(red: 0.953, green: 0.933, blue: 0.992))
            .cornerRadius(16)
            .foregroundColor(Color(red: 0.592, green: 0.408, blue: 0.996))
        }
        .padding()
    }
}

struct PromptView_Previews: PreviewProvider {
    static var previews: some View {
        PromptView(prompt: .constant(""))
    }
}
