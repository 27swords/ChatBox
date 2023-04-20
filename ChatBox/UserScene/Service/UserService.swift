//
//  UserService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 20/4/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

enum UserServiceError: Error {
    case userNotLoggedIn
    case failedToRetrieveData
    case failedToUploadAvatar
}

final class UserService {
    
    private let database = Firestore.firestore()
    private let auth = Auth.auth()
    
    //MARK: - UserGet methods
    public func userInfo() async throws -> [DTO] {
        guard let email = auth.currentUser?.email else { throw UserServiceError.userNotLoggedIn }
        
        let query = database.collection("users")
            .whereField("email", isEqualTo: email)
        
        do {
            let snapshot = try await query.getDocuments()
            let user = snapshot.documents.compactMap { document -> DTO? in
                guard let nickname = document.data()["nickname"] as? String else { return nil }
                guard let avatarURL = document.data()["avatarURL"] as? String else { return nil }
                return DTO(id: document.documentID, email: email, password: "", nickname: nickname, avatarURL: avatarURL)
            }
            return user
        } catch {
            throw UserServiceError.failedToRetrieveData
        }
    }
    
    // MARK: - update/upload photos
    /// Save an image to Firebase Storage and return its download URL
    public func uploadAvatar(image: UIImage) async throws -> URL {
        guard let currentUserId = auth.currentUser?.uid else {
            throw UserServiceError.userNotLoggedIn
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            throw UserServiceError.userNotLoggedIn
        }
        
        let storageRef = Storage.storage().reference()
        let avatarsRef = storageRef.child("avatars")
        let userAvatarRef = avatarsRef.child(currentUserId)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            // Create the user's avatar folder
            userAvatarRef.putData(Data())
            
            // Upload the avatar image to the user's folder
            let avatarImageRef = userAvatarRef.child("avatar.jpg")
            avatarImageRef.putData(imageData, metadata: metadata)
            
            // Return the download URL of the uploaded avatar image
            return try await avatarImageRef.downloadURL()
        } catch {
            throw error
        }
    }


    /// Update the user's profile with the given avatar URL
    public func updateUserProfile(avatarURL: URL) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw UserServiceError.userNotLoggedIn
        }
        
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        do {
            // Use a batched write to update the user's profile
            let batch = Firestore.firestore().batch()
            batch.updateData(["avatarURL": avatarURL.absoluteString], forDocument: userRef)
            try await batch.commit()
        } catch {
            throw error
        }
    }
}
