//
//  UserService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 28/3/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

final class UserService {
    
    let dataBase = Firestore.firestore()
    
    func userInfo(completion: @escaping ([UserModel]) -> ()) {
        guard let email = Auth.auth().currentUser?.email else { return }
        
        let query = dataBase.collection("users")
            .whereField("email", isEqualTo: email)
        
        query.getDocuments { snapshot, error in
            DispatchQueue.main.async {
                guard let snapshot = snapshot else { return }
                let userInfo = snapshot.documents.compactMap { document -> UserModel? in
                    guard let nickname = document.data()["nickname"] as? String else { return nil }
                    return UserModel(id: document.documentID, nickname: nickname, email: email)
                }
                completion(userInfo)
            }
        }
    }
    
    // сохранение изображениия в storage
    func uploadAvatar(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Storage.storage().reference().child("avatars").child(currentUserId)
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        let metadata = StorageMetadata()
        
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) { metadata, error in
            guard metadata != nil else {
                completion(.failure(error!))
                return
            }
            
            ref.downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }
        
    //отправление url фоторафии в коллекцию user
    func updateUserProfile(avatarURL: URL) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        userRef.updateData(["avatarURL": avatarURL.absoluteString]) { error in
            if let error = error {
                print("Error updating user profile: \(error.localizedDescription)")
            }
        }
    }
}
