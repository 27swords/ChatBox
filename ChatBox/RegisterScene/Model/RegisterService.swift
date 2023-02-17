//
//  RegisterService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 6/2/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

final class RegisterService {
    
    lazy var configEmail = ConfigEmail()
    
    //MARK: - Methods
    func createNewUser(_ data: LoginModel, completion: @escaping (RegisterResponse) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            Auth.auth().createUser(withEmail: data.email, password: data.password) { result, error in
                DispatchQueue.main.async {
                    guard error == nil else {
                        self.emailIsBusy(data: data)
                        completion(.alreadyInUse)
                        return
                    }
                    guard let result = result else {
                        completion(.error)
                        return
                    }
                    let userUid = result.user.uid
                    let email = data.email
                    let data: [String: Any] = ["email": email]
                    Firestore.firestore().collection("users").document(userUid).setData(data)
                    self.configEmail.configEmail()
                    completion(.success)
                }
            }
        }
    }
        
    //проверка зарегестрирован ли email
    func emailIsBusy(data: LoginModel) {
        DispatchQueue.global(qos: .userInitiated).async {
            Auth.auth().fetchSignInMethods(forEmail: data.email) { signInMethods, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("error emailIsBusy: \(error)")
                    } else if signInMethods == nil {
                        // электронная почта не используется
                    } else {
                        // электронная почта уже используется
                    }
                }
            }
        }
    }
}

