//
//  RegisterModel.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 6/2/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

final class RegisterModel {
    
    //MARK: - Singleton
    static let shared = RegisterModel()
    init() {}
    
    //MARK: - Methods
    func createNewUser(_ data: LoginModel, completion: @escaping (RegisterResponse) -> ()) {
        Auth.auth().createUser(withEmail: data.email, password: data.password) { result, error in
            if error == nil {
                completion(.error)
                if result != nil {
                    let userUid = result?.user.uid
                    let email = data.email
                    let data: [String: Any] = ["email": email]
                    Firestore.firestore().collection("users").document(userUid ?? "").setData(data)
                    
                    completion(.success)
                }
            } else {
                completion(.alreadyInUse)
            }
        }
    }
    
    func configEmail() {
        Auth.auth().currentUser?.sendEmailVerification(completion: { error in
            if error != nil {
                print("error!!!!")
            }
        })
    }
}

