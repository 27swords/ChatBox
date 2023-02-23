//
//  ChatCollectionViewCell.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 23/2/2023.
//

import UIKit
import MessageKit

class ChatCollectionViewCell: MessageContentCell {
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError("MessagesDisplayDelegate has not been set")
        }
        
        switch message.kind {
            
        case .text(let text):
            MessageLabel().text = text
            MessageLabel().textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
            messageContainerView.backgroundColor = .green // set the background color to green
        default:
            fatalError("Unsupported message kind: \(message.kind)")
        }
    }
    
}

