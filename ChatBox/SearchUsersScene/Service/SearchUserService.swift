//
//  SearchUserService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 10/5/2023.
//

import Foundation
import FirebaseFirestore
import Firebase

enum UsersServiceError: Error {
    case userNotLoggedIn
    case failedToRetrieveData
    case errorUserId
}

final class SearchUserService {
    
    //MARK: - Inits
    private let database = Firestore.firestore()
    private let auth = Auth.auth()
    
    //MARK: - Public Methods
    ///show a list of existing users
    public func getUsersList() async throws -> [DTO] {
        guard let email = auth.currentUser?.email else { throw UsersServiceError.userNotLoggedIn }
        
        let query = database.collection("users")
            .whereField("email", isNotEqualTo: email)
        
        do {
            let snapshot = try await query.getDocuments()
            let users = snapshot.documents.compactMap { document -> DTO? in
                guard let userIconURL = document.data()["userIconURL"] as? String else { return nil }
                guard let username = document.data()["username"] as? String else { return nil }
                
                let data = DTO()
                data.id = document.documentID
                data.username = username
                data.userIconURL = userIconURL
                return data
            }
            return users
        } catch {
            throw UsersServiceError.failedToRetrieveData
        }
    }
    
    ///subscribe to a user
    public func subscribeToUsers(userId: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else { throw UsersServiceError.userNotLoggedIn }
        
        let currentUserRef = database.collection("users").document(currentUserId)
        let userRef = database.collection("users").document(userId)
        
        do {
            let currentUserData = try await currentUserRef.getDocument()
            let userData = try await userRef.getDocument()
            let userDocId = userData.documentID
            var currentUserFriends = currentUserData.data()?["friends"] as? [String] ?? []
            
            if !currentUserFriends.contains(userDocId) {
                currentUserFriends.append(userDocId)
                let batch = database.batch()
                batch.updateData(["friends": currentUserFriends], forDocument: currentUserRef)
                try await batch.commit()
            }
            
            var otherUser = userData.data()?["friends"] as? [String] ?? []
            if !otherUser.contains(currentUserId) {
                otherUser.append(currentUserId)
                let batch = database.batch()
                batch.updateData(["friends": otherUser], forDocument: userRef)
                try await batch.commit()
            }
        } catch {
            throw UsersServiceError.failedToRetrieveData
        }
    }
    
    public func checkIfUserIsSubscribed(user: DTO) async throws -> Bool {
        guard let currentUser = auth.currentUser else { return false }
        let currentUserRef = database.collection("users").document(currentUser.uid)
        do {
            let snapshot = try await currentUserRef.getDocument()
            let currentUserData = snapshot.data()
            if let friends = currentUserData?["friends"] as? [String] {
                return friends.contains(user.id)
            }
        } catch {
            print("Error checkIfUserIsSubscribed", error.localizedDescription)
        }
        return false
    }
}
