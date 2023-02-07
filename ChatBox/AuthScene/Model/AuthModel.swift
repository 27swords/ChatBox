//
//  AuthModel.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 7/2/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

class AuthModel {
    
    //MARK: - Singleton
    static let shared = AuthModel()
    init() {}
    
    func authInApp(_ data: LoginModel, completion: @escaping (AuthResponse) -> ()) {
        Auth.auth().signIn(withEmail: data.email, password: data.password) { result, error in
            if error != nil {
                completion(.error)
            } else {
                if let result = result {
                    if result.user.isEmailVerified {
                        completion(.success)
                    } else {
                        completion(.notVerify)
                    }
                }
            }
        }
    }
}

