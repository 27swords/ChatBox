//
//  RegisterService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 20/4/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

enum RegisterResponse {
    case success
    case emailAlreadyInUse
    case usernameAlreadyInUse
    case error
    case unknownError
}

final class RegisterService {
    
    //MARK: - Inits
    private let database = Firestore.firestore()
    private let auth = Auth.auth()
    
    //MARK: - Registration methods
    ///registering a new user
    public func createNewUser(_ data: DTO, completion: @escaping (RegisterResponse) -> Void) async {
        
        do {
            let emailBusy = try await isEmailBusy(data.email)
            if emailBusy {
                completion(.emailAlreadyInUse)
                return
            }
            
            let nicknameBusy = await isUsernameBusu(data.username)
            if nicknameBusy  {
                completion(.usernameAlreadyInUse)
                return
            }
            
            let authResult = try await createUser(data.email, data.password, data.username, data.userIconURL)
            try await sendEmailVerifiCation(authResult)
            
            completion(.success)
        } catch {
            completion(.error)
        }
    }
    
    ///checking whether mail exists in the database
    private func isEmailBusy(_ email: String) async throws -> Bool {
        let signInMethods = try await auth.fetchSignInMethods(forEmail: email)
        return !signInMethods.isEmpty
    }
    
    ///checking whether the user name exists in the database
    private func isUsernameBusu(_ nickname: String) async -> Bool {
        let querySnapshot = try? await database.collection("users")
            .whereField("username", isEqualTo: nickname)
            .getDocuments()
        return querySnapshot?.documents.count ?? 0 > 0
    }
    
    ///registering a new user
    private func createUser(_ email: String, _ password: String, _ username: String, _ userIconURL: String?) async throws -> AuthDataResult {
        let authResult = try await auth.createUser(withEmail: email, password: password)
        let changeRequest = authResult.user.createProfileChangeRequest()
        changeRequest.displayName = username
        
        if let userIconURL = userIconURL {
            changeRequest.photoURL = URL(string: userIconURL)
        }
        try await changeRequest.commitChanges()
        let data: [String: Any] = ["id": authResult.user.uid, "email": email, "username": username, "userIconURL": userIconURL ?? "",]
        try await database.collection("users").document(authResult.user.uid).setData(data)
        
        return authResult
    }
    
    ///sending a confirmation email after successful registration
    private func sendEmailVerifiCation(_ authResult: AuthDataResult) async throws {
        try await authResult.user.sendEmailVerification()
        configEmail()
    }
    
    ///checking whether the user has confirmed their email address
    public func configEmail() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.auth.currentUser?.sendEmailVerification(completion: { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("error configEmail: \(error)")
                    }
                }
            })
        }
    }
}
