//
//  ChatListService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 10/4/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Conversation {
    let otherId: String
    let lastMessage: String
    let nickname: String
    let avatarUrl: String?
}
    
final class ChatListService {
    
    private let database = Firestore.firestore()
    private let auth = Auth.auth()
    
    func getConversations() async throws -> [Conversation] {
        guard let uid = auth.currentUser?.uid else { throw ChatServiceError.invalidData }
        
        let query = database.collection("conversations")
            .whereField("members", arrayContains: uid)
                
        do {
            let snapshot = try await query.getDocuments()
            let conversations = try await getConversationData(snapshot: snapshot.documents, currentUserID: uid)
            return conversations
        } catch {
            throw ChatServiceError.failedToRetrieveData
        }
    }
    
    private func getConversationData(snapshot: [QueryDocumentSnapshot], currentUserID: String) async throws -> [Conversation] {
        var conversations = [Conversation]()
        
        for document in snapshot {
            guard let otherId = (document.data()["members"] as? [String])?.filter({ $0 != currentUserID }).first else { continue }
            guard let nicknames = document.data()["nicknames"] as? [String: String], let nickname = nicknames[otherId] else { continue }
            guard let lastMessageData = document.data()["lastMessage"] as? [String: Any], let lastMessage = lastMessageData["text"] as? String else { continue }
            
            let avatarUrl = try await getAvatarUrlForUser(userID: otherId)
            conversations.append(Conversation(otherId: otherId, lastMessage: lastMessage, nickname: nickname, avatarUrl: avatarUrl))
        }
        
        return conversations
    }
    
    private func getAvatarUrlForUser(userID: String) async throws -> String? {
        let userQuery = database.collection("users").document(userID)
        do {
            let userDocument = try await userQuery.getDocument()
            return userDocument.data()?["avatarURL"] as? String
        } catch {
            throw ChatServiceError.failedToRetrieveData
        }
    }
}


