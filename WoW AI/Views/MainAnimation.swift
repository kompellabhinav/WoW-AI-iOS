//
//  MainAnimation.swift
//  WoW AI
//
//  Created by Abhinav Kompella on 4/28/24.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var filename: String
    var isPlaying: Bool

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView(name: filename)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        if isPlaying {
            animationView.play()
        } else {
            animationView.pause()
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        let animationView = uiView.subviews.first(where: { $0 is LottieAnimationView}) as? LottieAnimationView
        if isPlaying {
            animationView?.play()
        } else {
            animationView?.pause()
        }
    }
}

