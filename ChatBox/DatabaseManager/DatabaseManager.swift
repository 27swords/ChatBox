//
//  DatabaseManager.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 14/4/2023.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

final class DatabaseManager {
    
    private let database = Firestore.firestore()
    
    //MARK: - Registration methods
    public func createNewUser(_ data: DTO, completion: @escaping (RegisterResponse) -> Void) async {
        do {
            let emailBusy = try await isEmailBusy(data.email)
            if emailBusy {
                completion(.emailAlreadyInUse)
                return
            }
            
            let nicknameBusy = await isNicknameBusu(data.nickname)
            if nicknameBusy  {
                completion(.nicknameAlreadyInUse)
                return
            }
            
            let authResult = try await createUser(data.email, data.password, data.nickname, data.avatarURL)
            try await sendEmailVerifiCation(authResult)
            
            completion(.success)
        } catch {
            completion(.error)
        }
    }
    
    private func isEmailBusy(_ email: String) async throws -> Bool {
        let signInMethods = try await Auth.auth().fetchSignInMethods(forEmail: email)
        return !signInMethods.isEmpty
    }
    
    private func isNicknameBusu(_ nickname: String) async -> Bool {
        let querySnapshot = try? await database.collection("users")
            .whereField("nickname", isEqualTo: nickname)
            .getDocuments()
        return querySnapshot?.documents.count ?? 0 > 0
    }
    
    private func createUser(_ email: String, _ password: String, _ nickname: String, _ avatarURL: String?) async throws -> AuthDataResult {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeRequest = authResult.user.createProfileChangeRequest()
        changeRequest.displayName = nickname
        
        if let avatarURL = avatarURL {
            changeRequest.photoURL = URL(string: avatarURL)
        }
        try await changeRequest.commitChanges()
        let data: [String: Any] = ["email": email, "nickname": nickname, "avatarURL": avatarURL ?? ""]
        try await database.collection("users").document(authResult.user.uid).setData(data)
        return authResult
    }
    
    private func sendEmailVerifiCation(_ authResult: AuthDataResult) async throws {
        try await authResult.user.sendEmailVerification()
        configEmail()
    }
    
    private func configEmail() {
        DispatchQueue.global(qos: .userInitiated).async {
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("error configEmail: \(error)")
                    }
                }
            })
        }
    }
    
    
    //MARK: - Auth methods
    public func authInApp(_ data: DTO) async throws -> AuthResponse {
        do {
            let result = try await Auth.auth().signIn(withEmail: data.email, password: data.password)
            let user = result.user
            if user.isEmailVerified {
                return .success
            } else {
                configEmail()
                return .errorAccountNotVerified
            }
        } catch let error as NSError {
            if error.code == AuthErrorCode.userNotFound.rawValue || error.code == AuthErrorCode.wrongPassword.rawValue {
                return .errorLogin
            } else {
                throw error
            }
        }
    }
    
    //MARK: - FriendsGet methods
    public func getUsersList() async throws -> [DTO] {
        let database = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else { throw FriendsServiceError.userNotLoggedIn }
        
        let query = database.collection("users")
            .whereField("email", isNotEqualTo: email)
        
        do {
            let snapshot = try await query.getDocuments()
            let friends = snapshot.documents.compactMap { document -> DTO? in
                guard let nickname = document.data()["nickname"] as? String else { return nil }
                guard let avatarURL = document.data()["avatarURL"] as? String else { return nil }
                return DTO(id: document.documentID, email: "", password: "", nickname: nickname, avatarURL: avatarURL)
            }
            return friends
        } catch {
            throw FriendsServiceError.failedToRetrieveData
        }
    }
    
    //MARK: - UserGet methods
    public func userInfo() async throws -> [DTO] {
        guard let email = Auth.auth().currentUser?.email else { throw UserServiceError.userNotLoggedIn }
        
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
    
    //MARK: - update/upload photos 
    /// сохранение изображениия в storage
    public func uploadAvatar(image: UIImage) async throws -> URL {
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
            return url
        } catch {
            throw error
        }
    }

    
    ///отправление url фоторафии в коллекцию user
    public func updateUserProfile(avatarURL: URL) async throws {
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
