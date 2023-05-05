//
//  ChatService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 20/2/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

enum ChatServiceError: Error {
    case noCurrentUser
    case invalidData
    case failedToRetrieveData
}

final class ChatService {
    
    private let database = Firestore.firestore()
    private let auth = Auth.auth()
        
    public func sendMessage(otherId: String?, conversationId: String?, text: String) async throws -> String {
        guard let uid = auth.currentUser?.uid else { throw ChatServiceError.noCurrentUser }

        let messageData: [String: Any] = [
            "date": Date(),
            "sender": uid,
            "text": text
        ]

        if let convoId = conversationId {
            let messageRef = database.collection("conversations").document(convoId).collection("messages").document()
            try await messageRef.setData(messageData)

            let convoRef = database.collection("conversations").document(convoId)
            var convoData = try await convoRef.getDocument().data() ?? [:]
            convoData["lastMessage"] = messageData
            try await convoRef.setData(convoData)
            return convoId
        } else {
            guard let otherId = otherId else {
                throw ChatServiceError.invalidData
            }

            do {
                let convoId = try await getConversationsId(otherId: otherId)

                let messageRef = database.collection("conversations").document(convoId).collection("messages").document()
                try await messageRef.setData(messageData)
                return convoId
            } catch {
                let convoId = UUID().uuidString

                let selfConversationData: [String: Any] = [
                    "date": Date(),
                    "otherId": otherId
                ]

                let otherConversationData: [String: Any] = [
                    "date": Date(),
                    "otherId": uid
                ]

                // Get user data for both users
                let usersRef = database.collection("users")
                let selfUser = try await usersRef.document(uid).getDocument().data()
                let otherUser = try await usersRef.document(otherId).getDocument().data()

                // Get the nicknames of both users
                let selfNickname = selfUser?["nickname"] as? String ?? ""
                let otherNickname = otherUser?["nickname"] as? String ?? ""


                // Add nicknames to convoData
                let convoData: [String: Any] = [
                    "date": Date(),
                    "members": [uid, otherId],
                    "nicknames": [uid: selfNickname, otherId: otherNickname],
                    "lastMessage": messageData
                ]

                let batch = database.batch()

                let selfConversationRef = database.collection("users").document(uid).collection("conversations").document(convoId)
                let otherConversationRef = database.collection("users").document(otherId).collection("conversations").document(convoId)
                let convoRef = database.collection("conversations").document(convoId)
                let messageRef = convoRef.collection("messages").document()

                batch.setData(convoData, forDocument: convoRef)
                batch.setData(selfConversationData, forDocument: selfConversationRef)
                batch.setData(otherConversationData, forDocument: otherConversationRef)
                batch.setData(messageData, forDocument: messageRef)

                try await batch.commit()
                return convoId
            }
        }
    }

    
    public func getConversationsId(otherId: String) async throws -> String {
        guard let uid = auth.currentUser?.uid else { throw ChatServiceError.noCurrentUser }
        
        let conversationRef = database
            .collection("users")
            .document(uid)
            .collection("conversations")
            .whereField("otherId", isEqualTo: otherId)
            .limit(to: 1)
        
        do {
            let snapshot = try await conversationRef.getDocuments()
            guard let document = snapshot.documents.first else {
                throw NSError(domain: "Document error", code: 404, userInfo: nil)
            }
            return document.documentID
        } catch {
            throw error
        }
    }
    
    public func getAllMessages(chatId: String, completion: @escaping ([Message]) -> Void) throws -> ListenerRegistration? {
        guard let uid = auth.currentUser?.uid else { throw ChatServiceError.invalidData }

        let query = database.collection("conversations")
            .document(chatId)
            .collection("messages")
            .order(by: "date", descending: false)

        let listener = query.addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching messages: \(error!)")
                return
            }

            var messages = [Message]()

            for document in querySnapshot.documents {
                let data = document.data()
                let userId = data["sender"] as? String
                let messageId = document.documentID
                let date = data["date"] as? Timestamp
                let sentDate = date?.dateValue()
                let text = data["text"] as? String
                let sender = Sender(senderId: userId == uid ? "1" : "2", displayName: "", photoURL: "")

                messages.append(Message(
                    sender: sender,
                    messageId: messageId,
                    sentDate: sentDate ?? Date(),
                    kind: .text(text ?? "")
                ))
            }

            completion(messages)
        }

        return listener
    }
}


