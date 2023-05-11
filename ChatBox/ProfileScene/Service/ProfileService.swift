//
//  ProfileService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 20/4/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

enum ProfileServiceError: Error {
    case userNotLoggedIn
    case failedToRetrieveData
    case failedToUploadAvatar
}

final class ProfileService {
    
    //MARK: - Inits
    private let database = Firestore.firestore()
    private let auth = Auth.auth()
    
    //MARK: - Public Methods
    
    public func profileGet() async throws -> [DTO] {
        guard let email = auth.currentUser?.email else { throw ProfileServiceError.userNotLoggedIn }
        
        let query = database.collection("users")
            .whereField("email", isEqualTo: email)
        
        do {
            let snapshot = try await query.getDocuments()
            let user = snapshot.documents.compactMap { document -> DTO? in
                guard let username = document.data()["username"] as? String else { return nil }
                guard let userIconURL = document.data()["userIconURL"] as? String else { return nil }
                return DTO(id: document.documentID, email: email, password: "", username: username, userIconURL: userIconURL)
            }
            return user
        } catch {
            throw ProfileServiceError.failedToRetrieveData
        }
    }
    
    /// Save an image to Firebase Storage and return its download URL
    public func uploadUserIcon(image: UIImage) async throws -> URL {
        guard let currentUserId = auth.currentUser?.uid else {
            throw ProfileServiceError.userNotLoggedIn
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            throw ProfileServiceError.userNotLoggedIn
        }
        
        let storageRef = Storage.storage().reference()
        let userIconsRef = storageRef.child("userIcons")
        let userAvatarRef = userIconsRef.child(currentUserId)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            let avatarImageRef = userAvatarRef.child("userIcon.jpg")
            avatarImageRef.putData(imageData, metadata: metadata)

            return try await avatarImageRef.downloadURL()
        } catch {
            throw error
        }
    }

    /// Update the user's profile with the given avatar URL
    public func updateUserProfile(userIconURL: URL) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw ProfileServiceError.userNotLoggedIn
        }
        
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        do {
            let batch = Firestore.firestore().batch()
            batch.updateData(["userIconURL": userIconURL.absoluteString], forDocument: userRef)
            try await batch.commit()
        } catch {
            throw error
        }
    }
}
