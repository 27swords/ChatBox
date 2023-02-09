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
    
    //MARK: - Methods
    func createNewUser(_ data: LoginModel, completion: @escaping (RegisterResponse) -> ()) {
        Auth.auth().createUser(withEmail: data.email, password: data.password) { result, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.emailIsBusy(data: data)
                    completion(.alreadyInUse)
                }
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
            DispatchQueue.main.async {
                self.configEmail()
                completion(.success)
            }
        }
    }
    
    //потверждение email
    func configEmail() {
        Auth.auth().currentUser?.sendEmailVerification(completion: { error in
            if let error = error {
                print("error configEmail: \(error)")
            }
        })
    }
    
    //проверка зарегестрирован ли email
    func emailIsBusy(data: LoginModel) {
        Auth.auth().fetchSignInMethods(forEmail: data.email) { signInMethods, error in
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
