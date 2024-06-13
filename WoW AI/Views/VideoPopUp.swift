//
//  VideoPopUp.swift
//  WoW AI
//
//  Created by Abhinav Kompella on 5/2/24.
//

import SwiftUI
import YouTubePlayerKit

struct VideoPopUp: View {
    
    let url: String?
    @State var youtubeURL: YouTubePlayer?
    @Binding var isVideoPoppedUp: Bool
    @Binding var blurRadius: CGFloat
    
    var body: some View {
        VStack {
            if let youtubeURL = youtubeURL {
                YouTubePlayerView(youtubeURL) { state in
                    switch state {
                    case .idle:
                        ProgressView()
                    case .ready:
                        EmptyView()
                            .onAppear(perform: {
                                youtubeURL.play()
                            })
                    case .error(let error):
                        Text(verbatim: "Youtube player not loaded --> \(error)")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
                .padding()
                .frame(height: 250)
            } else {
                Text("No video URL Recieved")
                    .foregroundStyle(.red)
                    .font(.title)
            }
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
        .onAppear(perform: {
            let urlString = url
            print("----> String on screen : \(urlString!)")
            youtubeURL = YouTubePlayer(source: .url(urlString!))
        })
    }
}
