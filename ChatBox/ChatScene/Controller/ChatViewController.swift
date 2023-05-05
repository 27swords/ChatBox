//
//  ChatViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 20/2/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import FirebaseFirestore

final class ChatViewController: MessagesViewController {
    
    //MARK: - Inits
    var chatID: String?
    var otherID: String?
    var messages = [Message]()
    let chatService = ChatService()
    let selfSender = Sender(senderId: "1", displayName: "", photoURL: "")
    private var listener: ListenerRegistration?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMessageCollectionView()
        setupSendButton()
        
        Task { @MainActor in
            await searchChat()
        }
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
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        let message = Message(sender: selfSender, messageId: "", sentDate: Date(), kind: .text(text))
        
        messages.append(message)
        Task { @MainActor in
            do {
                let convoId = try await chatService.sendMessage(otherId: self.otherID, conversationId: self.chatID, text: text)
                
                DispatchQueue.main.async {
                    inputBar.inputTextView.text = nil
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                }
                self.chatID = convoId
            } catch {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}

//MARK: - Private Extension
private extension ChatViewController {
    
    //create CollectionView
    private func setupMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        showMessageTimestampOnSwipeLeft = true
    }
    
    private func setupSendButton() {
        messageInputBar.delegate = self
    }
    
    private func searchChat() async {
        guard chatID == nil else { return }
        
        do {
            let chatId = try await chatService.getConversationsId(otherId: otherID ?? "")
            self.chatID = chatId
            getMessages(chatId: chatId)
        } catch {
            print("Error fetching conversation ID: \(error.localizedDescription)")
        }
    }
        
    private func getMessages(chatId: String) {
        do {
            listener = try chatService.getAllMessages(chatId: chatId) { [weak self] messages in
                guard let self = self else { return }
                self.messages = messages
                self.messagesCollectionView.reloadDataAndKeepOffset()
            }
        } catch {
            print("Error fetching messages: \(error.localizedDescription)")
        }
    }
}
