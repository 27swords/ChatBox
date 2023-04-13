//
//  AuthService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 7/2/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

final class AuthService {
    
    lazy var configEmail = ConfigEmail()
    
    func authInApp(_ data: DTO) async throws -> AuthResponse {
        do {
            let result = try await Auth.auth().signIn(withEmail: data.email, password: data.password)
            let user = result.user
            if user.isEmailVerified {
                return .success
            } else {
                self.configEmail.configEmail()
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
}


