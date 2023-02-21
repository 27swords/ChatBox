//
//  ChatViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 20/2/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView

final class ChatViewController: MessagesViewController {

    //MARK: - Inits
    var chatID: String?
    var otherID: String?
    let service = ChatService()
    let selfSender = Sender(senderId: "1", displayName: "Me")
    let otherSender = Sender(senderId: "2", displayName: "alex")
    
    var messages = [Message]()
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        messages.append(Message(
            sender: selfSender,
            messageId: "1", sentDate: Date().addingTimeInterval(-11200),
            kind: .text("Hello")))
        
        messages.append(Message(
            sender: otherSender,
            messageId: "2", sentDate: Date().addingTimeInterval(-10200),
            kind: .text("Hello!!!")))
        
        setupMessageCollectionView()
        setupSendButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}

//MARK: - Messages Exntension
extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate, MessagesDataSource {
    
    var currentSender: MessageKit.SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}


//MARK: - InputBarAccessoryView Extension
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text(text))
        
        messages.append(message)
        service.sendMessage(otherId: self.otherID, conversationId: self.chatID, message: message, text: text) { [weak self] isSend in
            DispatchQueue.main.async {
                inputBar.inputTextView.text = nil
                self?.messagesCollectionView.reloadDataAndKeepOffset()
            }
        }
    }
}

//MARK: - Private Extension
private extension ChatViewController {

    func setupMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        showMessageTimestampOnSwipeLeft = true
    }
    
    func setupSendButton() {
        messageInputBar.delegate = self
    }
}
