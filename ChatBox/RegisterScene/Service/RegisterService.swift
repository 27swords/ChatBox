//
//  RegisterService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 20/4/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

enum RegisterResponse {
    case success
    case emailAlreadyInUse
    case nicknameAlreadyInUse
    case error
    case unknownError
}

final class RegisterService {
    
    private let database = Firestore.firestore()
    private let auth = Auth.auth()
    
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
        let signInMethods = try await auth.fetchSignInMethods(forEmail: email)
        return !signInMethods.isEmpty
    }
    
    private func isNicknameBusu(_ nickname: String) async -> Bool {
        let querySnapshot = try? await database.collection("users")
            .whereField("nickname", isEqualTo: nickname)
            .getDocuments()
        return querySnapshot?.documents.count ?? 0 > 0
    }
    
    private func createUser(_ email: String, _ password: String, _ nickname: String, _ avatarURL: String?) async throws -> AuthDataResult {
        let authResult = try await auth.createUser(withEmail: email, password: password)
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
