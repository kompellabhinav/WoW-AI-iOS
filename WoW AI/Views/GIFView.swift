//
//  GIFView.swift
//  WoW AI
//
//  Created by Abhinav Kompella on 4/18/24.
//

import Foundation
import SwiftUI

struct GIFView: UIViewRepresentable {
    let gifURL: URL
    
    func makeUIView(context: UIViewRepresentableContext<GIFView>) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: UIViewRepresentableContext<GIFView>) {
        guard let data = try? Data(contentsOf: gifURL) else {
            return
        }
        
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return
        }
        
        var images: [UIImage] = []
        let count = CGImageSourceGetCount(source)
        
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = UIImage(cgImage: cgImage)
                images.append(image)
            }
        }
        
        uiView.animationImages = images
        uiView.animationDuration = TimeInterval(count) * 0.03 // Adjust animation speed if needed
        uiView.contentMode = .scaleAspectFit
        uiView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        uiView.startAnimating()
    }
}

