//
//  FriendsService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 17/2/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

enum FriendsServiceError: Error {
    case userNotLoggedIn
    case failedToRetrieveData
}

final class FriendsService {
    
    func getUsersList() async throws -> [FriendsModel] {
        let database = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else { throw FriendsServiceError.userNotLoggedIn }
        
        let query = database.collection("users")
            .whereField("email", isNotEqualTo: email)
        
        do {
            let snapshot = try await query.getDocuments()
            let friends = snapshot.documents.compactMap { document -> FriendsModel? in
                guard let nickname = document.data()["nickname"] as? String else { return nil }
                guard let avatarURL = document.data()["avatarURL"] as? String else { return nil }
                return FriendsModel(id: document.documentID, nickname: nickname, avatarURL: avatarURL)
            }
            return friends
        } catch {
            throw FriendsServiceError.failedToRetrieveData
        }
    }
}



