//
//  HistoryScreen.swift
//  WoW AI
//
//  Created by Abhinav Kompella on 5/1/24.
//

import SwiftUI
import CoreData

struct HistoryScreen: View {
    @Environment(\.dismiss) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \QuestionEntity.date, ascending: true)],
        animation: .default)
    private var questions: FetchedResults<QuestionEntity>
    @State var videoURL: String?
    @State var isVideoPoppedUp = false
    @State var blurRadius: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.97)
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.callAsFunction()
                    }, label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 30)
                            .foregroundStyle(Color("ThemePink"))
                            .padding()
                    })
                    Spacer()
                    Button(action: deleteAllQuestions, label: {
                        Image(systemName: "trash.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 30)
                            .foregroundStyle(Color("ThemePink"))
                            .padding()
                    })
                }
                .background(Color.white)
                
                if questions.count == 0 {
                    Spacer()
                    Image(systemName: "archivebox")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(Color("ThemePink"))
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            
                            ForEach(questions, id: \.self) { question in
                                QuestionCard(question: question.question!, date: "\(question.date!)", url: question.url!, onTap: {
                                    self.videoURL = question.url
                                    self.blurRadius = 6
                                    self.isVideoPoppedUp = true
                                })
                            }
                            Spacer()
                            
                        }
                    }
                    .padding()
                }
            }
            .blur(radius: blurRadius)
            if isVideoPoppedUp {
                VideoPopUp(isVideoPoppedUp: $isVideoPoppedUp, blurRadius: $blurRadius, videoUrl: self.videoURL!)
            }
        }
    }
    
    func deleteAllQuestions() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = QuestionEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(batchDeleteRequest)
            viewContext.reset()
        } catch {
            print("Error deleting questions: \(error)")
        }
    }
}

#Preview {
    HistoryScreen()
}

struct QuestionCard: View {
    
    var question: String
    var date: String
    var url: String
    var onTap : () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(question.dropLast())
                    .padding(.bottom, 2)
                Text(date)
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
            .padding(.leading, 10)
            Spacer()
            Button(action: onTap, label: {
                Image(systemName: "play.fill")
                    .resizable()
                    .foregroundStyle(Color.white)
                    .padding()
            })
            .frame(width: 50, height: 50)
            .background(Color("ThemePink"))
            .clipShape(Circle())
            .padding()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear(perform: {
        })
    }
    
    func playButtonTapped() {
        print(url)
    }
}

struct Question: Hashable {
    let id = UUID()
    let question: String
    let date: String
    let url: String
}
