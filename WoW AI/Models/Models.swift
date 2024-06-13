//
//  Models.swift
//  WoW AI
//
//  Created by Abhinav Kompella on 4/18/24.
//

import Foundation

enum VoiceChatState {
    case idle
    case screenStartUp
    case recordingAudio
    case processingAudio
    case playingAudio
    case urlRecieved
    case nullRecieved
    case error(Error)
}
