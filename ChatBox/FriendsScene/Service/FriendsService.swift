//
//  FriendsService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 20/4/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

enum FriendsServiceError: Error {
    case userNotLoggedIn
    case failedToRetrieveData
    case errorUid
}

final class FriendsService {
    
    private let database = Firestore.firestore()
    private let auth = Auth.auth()
    
    public func getFriendsList() async throws -> [DTO] {
        guard let currentUserId = auth.currentUser?.uid else { throw FriendsServiceError.userNotLoggedIn }
        let currentUserRef = database.collection("users").document(currentUserId)
        let currentUserData = try await currentUserRef.getDocument()
        guard let friendIds = currentUserData.data()?["friends"] as? [String], !friendIds.isEmpty else { return [] }
        
        let query = database.collection("users")
            .whereField("id", in: friendIds)
        
        do {
            let snapshot = try await query.getDocuments()
            let friends = snapshot.documents.compactMap { document -> DTO? in
                guard let nickname = document.data()["nickname"] as? String else { return nil }
                guard let avatarUrl = document.data()["avatarURL"] as? String else { return nil }
                return DTO(id: document.documentID, email: "", password: "", nickname: nickname, avatarURL: avatarUrl)
            }
            return friends
        } catch {
            throw FriendsServiceError.failedToRetrieveData
        }
    }
    
    public func deleteFriends(friendID: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else { throw FriendsServiceError.userNotLoggedIn }
        let currentUserRef = database.collection("users").document(currentUserId)
        try await currentUserRef.updateData([
            "friends": FieldValue.arrayRemove([friendID])
        ])
        
        let friendRef = database.collection("users").document(friendID)
            try await friendRef.updateData([
                "friends": FieldValue.arrayRemove([currentUserId])
            ])
    }
}
