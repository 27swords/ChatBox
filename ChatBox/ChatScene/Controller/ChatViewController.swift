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
    lazy var service = ChatService()
    let selfSender = Sender(senderId: "1", displayName: "")
    let otherSender = Sender(senderId: "2", displayName: "")
    
    var messages = [Message]()
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMessageCollectionView()
        setupSendButton()
        searchChat()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Methods
    
    func searchChat() {
        guard chatID == nil else { return }
        service.getConversationsId(otherId: otherID ?? "") { [weak self] result in
            switch result {
            case .success(let chatId):
                self?.chatID = chatId
                self?.getMessages(chatId: chatId)
            case .failure(let error):
                print("Error fetching conversation ID: \(error.localizedDescription)")
                // Handle the error as needed
            }
        }
    }
    
    func getMessages(chatId: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.service.getAllMessages(chatId: chatId) { messages in
                DispatchQueue.main.async {
                    self.messages = messages
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                }
            }
        }
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
        let message = Message(sender: selfSender, messageId: "", sentDate: Date(), kind: .text(text))
        
        messages.append(message)
        service.sendMessage(otherId: self.otherID, conversationId: self.chatID, text: text) { [weak self] convoId in
            DispatchQueue.main.async {
                inputBar.inputTextView.text = nil
                self?.messagesCollectionView.reloadDataAndKeepOffset()
            }
            self?.chatID = convoId
        }
    }
}

//MARK: - Private Extension
private extension ChatViewController {

    //create CollectionView
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
