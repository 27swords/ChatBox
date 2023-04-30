//
//  SearchFriendsService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 27/4/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

enum FriendsServiceErrorr: Error {
    case userNotLoggedIn
    case failedToRetrieveData
    case errorFriendID
}

final class SearchFriendsService {
    
    private let database = Firestore.firestore()
    private let auth = Auth.auth()
    
    public func getFriendsList() async throws -> [DTO] {
        guard let email = auth.currentUser?.email else { throw FriendsServiceErrorr.userNotLoggedIn }

        let query = database.collection("users")
            .whereField("email", isNotEqualTo: email)

        do {
            let snapshot = try await query.getDocuments()
            let friends = snapshot.documents.compactMap { document -> DTO? in
                guard let avatarURL = document.data()["avatarURL"] as? String else { return nil }
                guard let nickname = document.data()["nickname"] as? String else { return nil }
                guard let friendEmail = document.data()["email"] as? String else { return nil }
                return DTO(id: document.documentID, email: friendEmail, password: "", nickname: nickname, avatarURL: avatarURL)
            }
            return friends
        } catch {
            throw FriendsServiceErrorr.failedToRetrieveData
        }
    }
    
    public func subscribeToFriend(friendID: String) async throws {
        guard let currentUserID = auth.currentUser?.uid else { throw FriendsServiceErrorr.userNotLoggedIn }
        let currentUserRef = database.collection("users").document(currentUserID)
        let friendRef = database.collection("users").document(friendID)
                
        do {
            let currentUserData = try await currentUserRef.getDocument()
            let friendData = try await friendRef.getDocument()
                    
            let friendID = friendData.documentID
                    
            // Add the friend's ID to the friends array in the current user document
            var currentUserFriends = currentUserData.data()?["friends"] as? [String] ?? []
            if !currentUserFriends.contains(friendID) {
                currentUserFriends.append(friendID)
                let batch = database.batch()
                batch.updateData(["friends": currentUserFriends], forDocument: currentUserRef)
                try await batch.commit()
            }
            
            // Add the current user's ID to the friends array in the friend user document
            var friendUserFriends = friendData.data()?["friends"] as? [String] ?? []
            if !friendUserFriends.contains(currentUserID) {
                friendUserFriends.append(currentUserID)
                let batch = database.batch()
                batch.updateData(["friends": friendUserFriends], forDocument: friendRef)
                try await batch.commit()
            }
        } catch {
            throw FriendsServiceErrorr.failedToRetrieveData
        }
    }
}
