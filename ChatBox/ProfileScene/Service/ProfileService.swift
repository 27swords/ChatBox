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
                let data = DTO()
                data.id = document.documentID
                data.email = email
                data.username = username
                data.userIconURL = userIconURL
                return data
            }
            return user
        } catch {
            throw ProfileServiceError.failedToRetrieveData
        }
    }
    
    /// Save an image to Firebase Storage and return its download URL    
    public func uploadUserIcon(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let currentUserId = auth.currentUser?.uid else {
            completion(.failure(ProfileServiceError.userNotLoggedIn))
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            completion(.failure(ProfileServiceError.userNotLoggedIn))
            return
        }
        
        let storageRef = Storage.storage().reference()
        let userIconsRef = storageRef.child("userIcons")
        let userAvatarRef = userIconsRef.child(currentUserId)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let avatarImageRef = userAvatarRef.child("userIcon.jpg")
        _ = avatarImageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
            } else {
                avatarImageRef.downloadURL { url, error in
                    if let url = url {
                        completion(.success(url))
                    } else if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(ProfileServiceError.failedToRetrieveData))
                    }
                }
            }
        }
    }


    /// Update the user's profile with the given avatar URL
    public func updateUserProfile(userIconURL: URL) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw ProfileServiceError.userNotLoggedIn
        }
        
        let userRef = Firestore.firestore().collection("users").document(currentUserId)
        
        do {
            try await userRef.updateData(["userIconURL": userIconURL.absoluteString])
            print("updateUserProfile: - \(userRef)")
        } catch {
            throw error
        }
    }
}
