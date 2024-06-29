//
//  ContentView.swift
//  WoW AI
//
//  Created by Abhinav Kompella on 4/18/24.
//

import SwiftUI
import CoreData

struct MainScreen: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var vm: ViewModel = ViewModel(context: ManagedObjectContextContainer.shared.context)
    @State var isBouncing = false
    @State var videoUrl: String?
    @State var isLottiePlaying = true
    @State var isHistoryScreenPresented = false
    @State var isSettingsScreenPresented = false
    @State var isVideoPoppedUp = false
    @State var blurRadius: CGFloat = 0.0
    let storage = StorePhoneNumber()
    
    var body: some View {
        ZStack {
            if storage.isFirstTime {
                PhoneNumberScreen(isEditScreen: false)
            } else {
                VStack {
                    LottieView(filename: "mainAnimation", isPlaying: isLottiePlaying)
                        .position(CGPoint(x: 200.0, y: 200))
                        .onAppear(perform: {
                            vm.state = .screenStartUp
                            Task {
                                await vm.startupAudio()
                            }
                        })
                    switch vm.state {
                    case .screenStartUp, .processingAudio, .playingAudio:
                        Color.clear
                            .frame(width: 0, height: 0)
                            .onAppear(perform: {
                                isLottiePlaying = true
                            })
                    case .idle, .recordingAudio:
                        Color.clear
                            .frame(width: 0, height: 0)
                            .onAppear(perform: {
                                isLottiePlaying = false
                            })
                    case .urlRecieved:
                        Color.clear
                            .frame(width: 0, height: 0)
                            .onAppear(perform: {
                                blurRadius = 6
                                isVideoPoppedUp = true
                            })
                        retryButton
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .position(x: 200, y: 250)
                    default: EmptyView()
                    }
                    switch vm.state {
                    case .nullRecieved:
                        retryButton
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .position(x: 200, y: 250)
                            .onAppear(perform: {
                                isLottiePlaying = false
                            })
                    default:
                        EmptyView()
                    }
                    HStack {
                        Button(action: {
                            isHistoryScreenPresented = true
                        }, label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .padding(.leading, 50)
                                .font(.system(size: 30))
                                .foregroundStyle(Color("ThemePink"))
                        })
                        .fullScreenCover(isPresented: $isHistoryScreenPresented, content: {
                            HistoryScreen()
                        })
                        Spacer()
                        switch vm.state {
                        case .processingAudio, .screenStartUp:
                            LottieView(filename: "loadingAnimation", isPlaying: true)
                                .frame(width: 120)
                        case .idle:
                            recordButton
                        case .recordingAudio:
                            stopRecording
                        case .nullRecieved:
                            callButton
                        default: EmptyView()
                        }
                        Spacer()
                        Button(action: {
                            isSettingsScreenPresented = true
                        }, label: {
                            Image(systemName: "gearshape.fill")
                                .padding(.trailing, 50)
                                .font(.system(size: 30))
                                .foregroundStyle(Color("ThemePink"))
                        })
                        .fullScreenCover(isPresented: $isSettingsScreenPresented, content: {
                            SettingsScreen()
                        })
                    }
                    .position(CGPoint(x: 200, y: 150.0))
                    
                    Spacer()
                }
                .blur(radius: blurRadius)
                if isVideoPoppedUp {
                    VideoPopUp(isVideoPoppedUp: $isVideoPoppedUp, blurRadius: $blurRadius, videoUrl: vm.videoUrl!)
                }
            }
        }
    }
    
    var recordButton: some View {
        Button(action: {
            vm.startCaptureAudio()
            isBouncing = true
        }, label: {
            Image(systemName: "mic.fill")
                .foregroundStyle(Color.white)
                .font(.system(size: 20))
        })
        .frame(width: 100, height: 100)
        .background(Color(red: 0.35, green: 0.42, blue: 0.78))
        .clipShape(Circle()) 
        
    }
    
    var stopRecording: some View {
        
        return Button(action: {
            vm.cancelRecording()
        }, label: {
            LottieView(filename: "recordWaveform", isPlaying: true) // Correct system image name
                .frame(width: 75) // Set the image frame
        })
        .frame(width: 100, height: 100)
        .background(Color(red: 0.35, green: 0.42, blue: 0.78))
        .clipShape(Circle())
        .onAppear(perform: {
        })
    }
    
    var callButton: some View {
        return Button(action: {}, label: {
            Image(systemName: "phone.fill")
                .resizable()
                .foregroundStyle(Color.white)
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
        })
        .frame(width: 100, height: 100)
        .background(Color(red: 0.27, green: 0.63, blue: 0.31))
        .clipShape(Circle())
    }
    
    var retryButton: some View {
        return Button(action: {
        }, label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        })
    }
    
    var urlRecievedScreen: some View {
        return VStack {
            PlayerViewController(videoURL: URL(string: videoUrl!))
                .padding()
                .frame(height: 250)
        }
    }
}

#Preview() {
    MainScreen()
}

class ManagedObjectContextContainer {
    static let shared = ManagedObjectContextContainer()
    var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
}

//#Preview("Screen Start Up") {
//    let vm = ViewModel()
//    vm.state = .screenStartUp
//    return MainScreen(vm: vm)
//}
//
//#Preview("Recording Audio") {
//    let vm = ViewModel()
//    vm.state = .recordingAudio
//    return MainScreen(vm: vm)
//}
//
//#Preview("Processing Audio") {
//    let vm = ViewModel()
//    vm.state = .processingAudio
//    return MainScreen(vm: vm)
//}
//
//#Preview("Playing Audio") {
//    let vm = ViewModel()
//    vm.state = .playingAudio
//    return MainScreen(vm: vm)
//}
//
//#Preview("URL Recieved") {
//    let vm = ViewModel()
//    vm.state = .urlRecieved
//    return MainScreen(vm: vm)
//}
//
//#Preview("Null Recieved") {
//    let vm = ViewModel()
//    vm.state = .nullRecieved
//    return MainScreen(vm: vm)
//}
//
//#Preview("Error") {
//    let vm = ViewModel()
//    vm.state = .error("An error has occured" as Error)
//    return MainScreen(vm: vm)
//}
