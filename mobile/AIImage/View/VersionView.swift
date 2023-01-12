//
//  VersionView.swift
//  AIImage
//
//  Created by Andrew Kochulab on 19.12.2022.
//

import SwiftUI

struct VersionView: View {
    private let versions = APIVersion.allCases
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ForEach(versions, id: \.self) { version in
                    NavigationLink(destination: ContentView()) {
                        Text(version.rawValue)
                            .font(Font.system(size: 15).weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            .tracking(1)
                    }.simultaneousGesture(TapGesture().onEnded({
                        NetworkService.shared.apiVersion = version
                    }))
                }
            }
        }
        .navigationBarTitle(Text("Select API Version"))
    }
}

struct VersionView_Previews: PreviewProvider {
    static var previews: some View {
        VersionView()
    }
}
