//
//  ChatService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 20/2/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

final class ChatService {
    
    func sendMessage(otherId: String?, conversationId: String?, message: Message, text: String, completion: @escaping (Bool) -> ()) {
        if conversationId == nil {
            
        } else {
            let message: [String: Any] = [
                "data": Date(),
                "sender": message.sender.senderId,
                "text": text
            ]
            
            Firestore.firestore().collection("conversations").document(conversationId ?? String()).collection("messages").addDocument(data: message) { error in
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func updateConversations() {
        
    }
    
    func getConversationsId() {
        
    }
    
    func getAllMessages() {
        
    }
    
    func getOneMessage() {
        
    }
}
