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
    
    func sendMessage(otherId: String?, conversationId: String?, text: String, completion: @escaping (String) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion("")
            return
        }

        let collections = Firestore.firestore()
        let messageData: [String: Any] = [
            "date": Date(),
            "sender": uid,
            "text": text
        ]

        if let convoId = conversationId {
            let messageRef = collections.collection("conversations").document(convoId).collection("messages").document()
            messageRef.setData(messageData) { error in
                if error == nil {
                    completion(convoId)
                }
            }
        } else {
            guard let otherId = otherId else {
                return
            }

            let convoId = UUID().uuidString

            let selfConversationData: [String: Any] = [
                "date": Date(),
                "otherId": otherId
            ]

            let otherConversationData: [String: Any] = [
                "date": Date(),
                "otherId": uid
            ]

            let convoData: [String: Any] = [
                "date": Date(),
                "members": [uid, otherId]
            ]

            let batch = collections.batch()

            let selfConversationRef = collections.collection("users").document(uid).collection("conversations").document(convoId)
            let otherConversationRef = collections.collection("users").document(otherId).collection("conversations").document(convoId)
            let convoRef = collections.collection("conversations").document(convoId)
            let messageRef = convoRef.collection("messages").document()

            batch.setData(convoData, forDocument: convoRef)
            batch.setData(selfConversationData, forDocument: selfConversationRef)
            batch.setData(otherConversationData, forDocument: otherConversationRef)
            batch.setData(messageData, forDocument: messageRef)

            batch.commit() { error in
                if error == nil {
                    completion(convoId)
                }
            }
        }
    }


    func updateConversations() {
        
    }
    
    func getConversationsId(otherId: String, completion: @escaping (Result<String, Error>) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth error", code: 401, userInfo: nil)))
            return
        }

        // Use a cached Firestore instance
        let firestore = Firestore.firestore()

        // Use a background thread for network operations
        DispatchQueue.global(qos: .background).async {
            let conversationRef = firestore
                .collection("users")
                .document(uid)
                .collection("conversations")
                .whereField("otherId", isEqualTo: otherId)
                .limit(to: 1)

            conversationRef.getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let document = snapshot?.documents.first else {
                    completion(.failure(NSError(domain: "Document error", code: 404, userInfo: nil)))
                    return
                }

                completion(.success(document.documentID))
            }
        }
    }

    func getAllMessages(chatId: String, completion: @escaping ([Message]) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        
        DispatchQueue.global(qos: .userInitiated).async {
            db.collection("conversations")
                .document(chatId)
                .collection("messages")
                .order(by: "date", descending: false)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot, error == nil, !snapshot.documents.isEmpty else {
                        return
                    }
                    
                    var messages = [Message]()
                    
                    for document in snapshot.documents {
                        let data = document.data()
                        let userId = data["sender"] as? String
                        let messageId = document.documentID
                       
                        let date = data["date"] as? Timestamp
                        let sentDate = date?.dateValue()
                        
                        let text = data["text"] as? String
                        
                        let sender = Sender(senderId: userId == uid ? "1" : "2", displayName: "")
                        
                        messages.append(Message(
                            sender: sender,
                            messageId: messageId,
                            sentDate: sentDate ?? Date(),
                            kind: .text(text ?? "")
                        ))
                    }
                    
                    DispatchQueue.main.async {
                        completion(messages)
                    }
                }
        }
    }

    
    func getOneMessage() {
        
    }
}

