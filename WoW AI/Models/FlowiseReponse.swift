//
//  FlowiseReponse.swift
//  WoW AI
//
//  Created by Abhinav Kompella on 6/29/24.
//

import Foundation

struct FlowiseReponse: Decodable {
    let text: String
    let question: String
    let chatId: String
    let chatMessageId: String
    let sessionId: String
}
