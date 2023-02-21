//
//  ChatModel.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 20/2/2023.
//

import Foundation
import MessageKit

    struct Sender: SenderType {
        var senderId: String
        var displayName: String
    }

    struct Message: MessageType {
        var sender: MessageKit.SenderType
        var messageId: String
        var sentDate: Date
        var kind: MessageKit.MessageKind
    }
