//
//  FriendsService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 17/2/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

final class FriendsService {
    
    func getUsersList(completion: @escaping ([FriendsModel]) -> ()) {
        let dataBase = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else { return }

        let query = dataBase.collection("users")
            .whereField("email", isNotEqualTo: email)

        query.getDocuments { snapshot, error in
            DispatchQueue.main.async {
                guard let snapshot = snapshot else { return }
                let chatListModel = snapshot.documents.compactMap { document -> FriendsModel? in
                    guard let nickname = document.data()["nickname"] as? String else { return nil }
                    guard let avatarURL = document.data()["avatarURL"] as? String else { return nil }
                    return FriendsModel(id: document.documentID, nickname: nickname, avatarURL: avatarURL) 
                }
                completion(chatListModel)
            }
        }
    }
}




