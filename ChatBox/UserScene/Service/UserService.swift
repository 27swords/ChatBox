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

enum UserServiceError: Error {
    case userNotLoggedIn
    case failedToRetrieveData
}

final class UserService {
    
    let dataBase = Firestore.firestore()
    
    func userInfo() async throws -> [UserModel] {
        guard let email = Auth.auth().currentUser?.email else { throw UserServiceError.userNotLoggedIn }
        
        let query = dataBase.collection("users")
            .whereField("email", isEqualTo: email)
        
        do {
            let snapshot = try await query.getDocuments()
            let user = snapshot.documents.compactMap { document -> UserModel? in
                guard let nickname = document.data()["nickname"] as? String else { return nil}
                return UserModel(id: document.documentID, nickname: nickname, email: email)
            }
            return user
        } catch {
            throw UserServiceError.failedToRetrieveData
        }
    }
    
    /// сохранение изображениия в storage
    func uploadAvatar(image: UIImage) async throws -> URL {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw UserServiceError.userNotLoggedIn
        }
        
        let ref = Storage.storage().reference().child("avatars").child(currentUserId)
        guard let imagedata = image.jpegData(compressionQuality: 0.4) else {
            throw UserServiceError.failedToRetrieveData
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            ref.putData(imagedata, metadata: metadata)
            
            let url = try await ref.downloadURL()
            let userRef = dataBase.collection("users").document(currentUserId)
            try await userRef.updateData(["avatarURL": url.absoluteString])
            
            return url
        } catch {
            throw error
        }
    }
    
    ///отправление url фоторафии в коллекцию user
    func updateUserProfile(avatarURL: URL) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw UserServiceError.userNotLoggedIn
        }
        
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        do {
            try await userRef.updateData(["avatarURL": avatarURL.absoluteString])
        } catch {
            throw error
        }
    }
}
