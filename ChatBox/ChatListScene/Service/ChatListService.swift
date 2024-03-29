//
//  ChatListService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 10/4/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
    
final class ChatListService {
    
    //MARK: - Inits
    private let database = Firestore.firestore()
    private let auth = Auth.auth()
    
    //MARK: - Public methods
    ///getting a list of all user dialogs
    public func getConversations() async throws -> [ChatListModel] {
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
    
    //MARK: - Private Methods
    ///getting detailed information about each dialog
    private func getConversationData(snapshot: [QueryDocumentSnapshot], currentUserID: String) async throws -> [ChatListModel] {
        var conversations = [ChatListModel]()
        
        for document in snapshot {
            guard let otherId = (document.data()["members"] as? [String])?.filter({ $0 != currentUserID }).first else { continue }
            guard let usernameData = document.data()["usernames"] as? [String: String] else { continue }
            guard let username = usernameData[otherId] else { continue }
            guard let lastMessageData = document.data()["lastMessage"] as? [String: Any] else { continue }
            guard let lastMessage = lastMessageData["text"] as? String else { continue }
            guard let lastMessageDate = lastMessageData["date"] as? Timestamp else { continue }
            
            let userIconURL = try await getUserIconURLForUser(userID: otherId)
            conversations.append(
                ChatListModel(
                    otherId: otherId,
                    lastMessage: lastMessage,
                    username: username,
                    date: lastMessageDate.dateValue(),
                    userIconURL: userIconURL))
        }
        
        return conversations
    }
    
    ///getting a user's photo
    private func getUserIconURLForUser(userID: String) async throws -> String? {
        let userQuery = database.collection("users").document(userID)
        do {
            let userDocument = try await userQuery.getDocument()
            return userDocument.data()?["userIconURL"] as? String
        } catch {
            throw ChatServiceError.failedToRetrieveData
        }
    }
}


