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
   
    func getUsersList(completion: @escaping ([CurrentUser]) -> ()) {

        let dataBase = Firestore.firestore()
        var currentUsers = [CurrentUser]()
        guard let email = Auth.auth().currentUser?.email else { return }

        let query = dataBase.collection("users")
            .whereField("email", isNotEqualTo: email)

        query.getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }

            for document in snapshot.documents {
                let data = document.data()
                if let email = data["email"] as? String {
                    let user = CurrentUser(id: document.documentID, email: email)
                    currentUsers.append(user)
                }
            }
            completion(currentUsers)
        }
    }
}





