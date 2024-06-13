//
//  ViewModel.swift
//  SpeechToText
//
//  Created by Abhinav Kompella on 3/24/24.
//

import AVFoundation
import Foundation
import Observation
import XCAOpenAIClient
import YouTubePlayerKit
import CoreData

@Observable
class ViewModel: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate, ObservableObject {
    
    private var viewContext: NSManagedObjectContext
    
    let client = OpenAIClient(apiKey: ProcessInfo.processInfo.environment["openAI_api_key"]!)
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    var recordingSession = AVAudioSession.sharedInstance()
    var animationTimer: Timer?
    var recordingTimer: Timer?
    var audioPower = 0.0
    var prevAudioPower: Double?
    var processingSpeechTask: Task<Void, Never>?
    var videoUrl : String?
    
    var aiAssist = AIAssistant()
    
    var captureURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("recoding.m4a")
    }
    
    var state = VoiceChatState.idle {
        didSet { print(state) }
    }
    
    var isIdle: Bool {
        if case .idle = state {
            return true
        }
        return false
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        super.init()
        do {
            try recordingSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try recordingSession.setActive(true)
            
            AVAudioApplication.requestRecordPermission { [unowned self]allowed in
                if !allowed {
                    self.state = .error("Recording not allowed by the user")
                }
            }
        } catch {
            state = .error(error)
        }
    }
    
    func startCaptureAudio() {
        resetValues()
        state = .recordingAudio
        do {
            audioRecorder = try AVAudioRecorder(url: captureURL, settings: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ])
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
            audioRecorder.record()
            
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self] _ in
                guard self.audioRecorder != nil else { return }
                self.audioRecorder.updateMeters()
                let power = min(1, max(0, 1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50 )))
                self.audioPower = power
            })
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true, block: { [unowned self] _ in
                guard self.audioRecorder != nil else { return }
                self.audioRecorder.updateMeters()
                let power = min(1, max(0, 1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50 )))
                if self.prevAudioPower == nil {
                    self.prevAudioPower = power
                    return
                }
                if let prevAudioPower = self.prevAudioPower, prevAudioPower < 0.25 && power < 0.175 {
                    self.finishCaptureAudio()
                }
                self.prevAudioPower = power
            })
        } catch {
            state = .error(error)
        }
    }
    
    func finishCaptureAudio() {
        resetValues()
        do {
            let data = try Data(contentsOf: captureURL)
//            try playAudio(data: data)
            processingSpeechTask = processSpeechTask(audioData: data)
        } catch {
            state = .error(error)
            resetValues()
        }
    }
    
    func processSpeechTask(audioData: Data) -> Task<Void, Never> {
        Task { @MainActor [unowned self] in
            do {
                print("dsljn")
                self.state = .processingAudio
                // Converts speech to text
                let prompt = try await client.generateAudioTransciptions(audioData: audioData)
                
                print(prompt)

                try Task.checkCancellation()
        
                await aiAssist.createMessage(message: prompt)
                print("------------ Messge created ------------")
                let responseText = aiAssist.messageResponse
                
                print(responseText!)
                
                if responseText! == "null" {
                    print("NULL recieved. Call button displayed")
                    state = .nullRecieved
                    return
                }
                
                if responseText![..<(responseText?.index(responseText!.startIndex, offsetBy: 8))!] == "https://" {
                    self.videoUrl = responseText
                    print("-------> URL: \(self.videoUrl ?? "url not parsed")")
                    saveQuestion(question: prompt, url: videoUrl!)
                    state = .urlRecieved
                    return
                }
                
                // Converts text to speech
                try Task.checkCancellation()
                let data = try await client.generateSpeechFrom(input: responseText!)
                
                try Task.checkCancellation()
                try self.playAudio(data: data)
                
                
                
            } catch {
                if Task.isCancelled { return }
                state = .error(error)
                resetValues()
            }
        }
    }
    
    func playAudio(data: Data) throws {
        self.state = .playingAudio
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer.isMeteringEnabled = true
        audioPlayer.delegate = self
        audioPlayer.play()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self] _ in
            guard self.audioPlayer != nil else { return }
            self.audioPlayer.updateMeters()
            let power = min(1, max(0, 1 - abs(Double(self.audioPlayer.averagePower(forChannel: 0)) / 160 )))
            self.audioPower = power
        })
    }
    
    func sendRecording() {
        self.finishCaptureAudio()
    }
    
    func cancelRecording() {
        self.finishCaptureAudio()
        resetValues()
        state = .idle
    }
    
    func cancelProcessingTask() {
        processingSpeechTask?.cancel()
        processingSpeechTask = nil
        resetValues()
        state = .idle
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            resetValues()
            state = .idle
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        resetValues()
        state = .idle
    }
    
    func resetValues() {
        audioPower = 0
        prevAudioPower = nil
        audioRecorder?.stop()
        audioRecorder = nil
        audioPlayer?.stop()
        audioPlayer = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
        animationTimer?.invalidate()
        animationTimer = nil
        videoUrl = nil
    }
    
    func saveQuestion(question: String, url: String) {
        let newQuestion = QuestionEntity(context: viewContext)
        newQuestion.question = question
        newQuestion.url = url
        newQuestion.date = Date()
        
        do {
            try viewContext.save()
            print("Question saved successfully")
        } catch {
            print("Failed to save question: \(error)")
        }
    }
    
    func call() {
        print("Call pressed")
    }
    
    func restartAssistant() {
        self.aiAssist = AIAssistant()
        state = .idle
    }
    
    func startupAudio() async {
        let welcomeAudio = "Hello! I am the RHL AI assistant, Please use the mic button below to let me know your concern"
        do {
            
            let data = try await client.generateSpeechFrom(input: welcomeAudio)
            
            try self.playAudio(data: data)
        } catch {
            state = .error(error)
            resetValues()
        }
    }
}
