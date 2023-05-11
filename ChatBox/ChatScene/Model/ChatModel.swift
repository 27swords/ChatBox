//
//  ChatModel.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 20/2/2023.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var photoURL: String
}
