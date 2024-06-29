import Foundation
import SwiftOpenAI
import Alamofire

class AIAssistant : ObservableObject {
    let assistantId = "asst_oRQaP4DJUSyY1srpPZM67STc"
    
    // Add your API key here or add it in the environment variable.
    let service : some OpenAIService = OpenAIServiceFactory.service(apiKey: ProcessInfo.processInfo.environment["openAI_api_key"]!)
    var threadId : String?
    var messageResponse : String?
    
    
    init() {
        createThread()
        print("thread created")
    }

    
    func createThread() -> Task<Void, Never> {
        Task { @MainActor [unowned self] in
            if threadId == nil {
                let params = CreateThreadParameters()
                let thread = try? await service.createThread(parameters: params)
                self.threadId = thread!.id
                print(" --->>> Create thread: \(threadId ?? "")")
            }
        }
    }
    
    func createMessage(message: String) async {
        let prompt = message
        let params = MessageParameter(role: MessageParameter.Role(rawValue: "user")!, content: prompt)
        let message = try? await service.createMessage(threadID: threadId!, parameters: params)
        print("--------> Create Message")
        
        await runThread()
        
    }
    
    func runThread() async {
        let params = RunParameter(assistantID: assistantId)
        let run = try? await service.createRun(threadID: threadId!, parameters: params)
        let runid = (run?.id)!
        var runStatus = "inProgress"
        while runStatus != "completed" {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            print("--->>> Trying! Status : \(runStatus)")
            runStatus = try! await service.retrieveRun(threadID: threadId!, runID: runid).status
        }
        await rertieveThread()
    }
    
    func rertieveThread() async {
        do {
            let messages = try await service.listMessages(threadID: threadId!, limit: nil, order: nil, after: nil, before: nil, runID: nil)
            if let firstMessage = messages.data.first,
               let firstContent = firstMessage.content.first,
               case let .text(textContent) = firstContent {
                print(textContent.text.value)
                self.messageResponse = textContent.text.value
                postThreadData()
            } else {
                print("Unable to extract value")
            }
        } catch {
            print(error)
        }
    }
    
    func postThreadData() {
        
        let params = [
            "phoneNumber": StorePhoneNumber().phoneNumber,
            "threadID": self.threadId
        ]
        
        print(params)
        
        guard let url = URL(string: "https://rhlaiservice.azurewebsites.net/api/savethreadid") else {
            print("Invalid URL")
            return
        }
        
        AF.request(url, method: .post, parameters: params as Parameters, encoding: JSONEncoding.default).response { response in
            print(response.debugDescription)
        }
    }
}
