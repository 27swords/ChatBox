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
}

final class FriendsService {
    
    private let database = Firestore.firestore()
    private let auth = Auth.auth()
    
    public func getUsersList() async throws -> [DTO] {
        guard let email = auth.currentUser?.email else { throw FriendsServiceError.userNotLoggedIn }

        let query = database.collection("users")
            .whereField("email", isNotEqualTo: email)

        do {
            let snapshot = try await query.getDocuments()
            let friends = snapshot.documents.compactMap { document -> DTO? in
                guard let nickname = document.data()["nickname"] as? String else { return nil }
                guard let avatarURL = document.data()["avatarURL"] as? String else { return nil }
                print("avatarURL", avatarURL)
                return DTO(id: document.documentID, email: "", password: "", nickname: nickname, avatarURL: avatarURL)

            }
            return friends
        } catch {
            throw FriendsServiceError.failedToRetrieveData
        }
    }
}
