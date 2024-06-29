//
//  VideoPlayer.swift
//  WoW AI
//
//  Created by Abhinav Kompella on 6/12/24.
//

import SwiftUI
import AVKit

struct PlayerViewController: UIViewControllerRepresentable {
    var videoURL: URL?

    private var player: AVPlayer {
        return AVPlayer(url: videoURL!)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.player = player
        
        return controller
    }

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {}
}
