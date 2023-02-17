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
    
    lazy var configEmail = ConfigEmail()
    
    func authInApp(_ data: LoginModel, completion: @escaping (AuthResponse) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            Auth.auth().signIn(withEmail: data.email, password: data.password) { result, error in
                DispatchQueue.main.async {
                    guard error == nil else {
                        completion(.error)
                        return
                    }

                    guard let user = result?.user else {
                        completion(.errorLogin)
                        return
                    }

                    if user.isEmailVerified {
                        completion(.success)
                    } else {
                        self.configEmail.configEmail()
                        completion(.errorAccountNotVerified)
                    }
                }
            }
        }
    }
}


