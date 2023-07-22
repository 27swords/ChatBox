//
//  AuthService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 20/4/2023.
//

import Foundation
import Firebase

enum AuthResponse {
    case success
    case errorAccountNotVerified
    case errorLogin
    case error
}

final class AuthService {
    
    //MARK: - Inits
    private let auth = Auth.auth()
    private let configEmail = RegisterService()
    
    //MARK: - public methods
    ///authorization in the application
    public func authInApp(_ data: DTO) async throws -> AuthResponse {
        do {
            let result = try await auth.signIn(withEmail: data.email, password: data.password)
            let user = result.user
            
            if user.isEmailVerified {
                return .success
            } else {
                configEmail.configEmail()
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
