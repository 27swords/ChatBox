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
    case failedToDeleteData
}

final class ChatService {
    
    //MARK: - Inits
    private let database = Firestore.firestore()
    private let auth = Auth.auth()
    
    //MARK: - Public methods
    ///sending a message to the user or creating a new chat if the dialog does not exist
    public func sendMessage(otherId: String?, conversationId: String?, text: String) async throws -> String {
        guard let uid = auth.currentUser?.uid else { throw ChatServiceError.noCurrentUser }
        
        let messageData: [String: Any] = [
            "date": Date(),
            "sender": uid,
            "text": text
        ]
        
        if let convoId = conversationId {
            try await sendMessageToExistingConversation(convoId: convoId, messageData: messageData)
            return convoId
        } else {
            guard let otherId = otherId else {
                throw ChatServiceError.invalidData
            }
            do {
                let convoId = try await getConversationsId(otherId: otherId)
                try await sendMessageToExistingConversation(convoId: convoId, messageData: messageData)
                return convoId
            } catch {
                let convoId = UUID().uuidString
                try await createNewConversation(uid: uid, otherId: otherId, convoId: convoId, messageData: messageData)
                return convoId
            }
        }
    }
    
    ///This method get the ID of a conversation between the current user and another user. It queries theFirestore database to find the conversation document in the "conversations" subcollection of the current user's document, where the "otherId" field is equal to the ID of the other user.
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
    
    ///method retrieve all the message in a conversation identified by chat Id.
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
    
    public func currentUserPhoto() async throws -> [String] {
        guard let email = auth.currentUser?.email else { throw ChatServiceError.noCurrentUser }
        
        let query = database.collection("users")
            .whereField("email", isEqualTo: email)
        
        do {
            let snapshot = try await query.getDocuments()
            let currentPhoto = snapshot.documents.compactMap { document -> String? in
                guard let userIconURL = document.data()["userIconURL"] as? String else { return nil }
                return userIconURL
            }
            return currentPhoto
        } catch {
            throw ChatServiceError.failedToRetrieveData
        }
    }
    
    //MARK: - Private methods
    ///adds the message to the specified conversation and updates the last message of the conversation.
    private func sendMessageToExistingConversation(convoId: String, messageData: [String: Any]) async throws {
        let messageRef = database.collection("conversations").document(convoId).collection("messages").document()
        try await messageRef.setData(messageData)
        
        let convoRef = database.collection("conversations").document(convoId)
        var convoData = try await convoRef.getDocument().data() ?? [:]
        convoData["lastMessage"] = messageData
        try await convoRef.setData(convoData)
    }
    
    /// creates a new conversation and adds the message to that conversation. It also updates the list of conversations for both users involved in the conversation.
    private func createNewConversation(uid: String, otherId: String, convoId: String, messageData: [String: Any]) async throws {
        let selfConversationData: [String: Any] = [
            "date": Date(),
            "otherId": otherId
        ]
        
        let otherConversationData: [String: Any] = [
            "date": Date(),
            "otherId": uid
        ]
        
        let usersRef = database.collection("users")
        let selfUser = try await usersRef.document(uid).getDocument().data()
        let otherUser = try await usersRef.document(otherId).getDocument().data()
        
        let selfUsername = selfUser?["username"] as? String ?? ""
        let otherUsername = otherUser?["username"] as? String ?? ""
        
        let convoData: [String: Any] = [
            "date": Date(),
            "members": [uid, otherId],
            "usernames": [uid: selfUsername, otherId: otherUsername],
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
    }
}


