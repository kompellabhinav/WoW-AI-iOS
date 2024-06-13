//
//  VideoPopUp.swift
//  WoW AI
//
//  Created by Abhinav Kompella on 5/2/24.
//

import SwiftUI

struct VideoPopUp: View {
    
    @Binding var isVideoPoppedUp: Bool
    @Binding var blurRadius: CGFloat
    let videoUrl: String
    
    var body: some View {
        VStack {
            PlayerViewController(videoURL: URL(string: videoUrl))
                .padding()
                .frame(height: 250)
            Button(action: {
                blurRadius = 0.0
                isVideoPoppedUp = false
            }, label: {
                Image(systemName: "xmark")
                    .resizable()
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding()
            })
            .frame(width: 60, height: 60)
            .background(Color.black.opacity(8))
            .clipShape(Circle())
        }
    }
}
