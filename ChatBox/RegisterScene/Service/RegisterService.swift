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

    //MARK: - Inits
    let db = Firestore.firestore()
    let configEmail = ConfigEmail()

    //MARK: - Methods
    func createNewUser(_ data: DTO, completion: @escaping (RegisterResponse) -> ()) {
        
        let group = DispatchGroup()
        var emailIsBusy = false
        var nicknameIsBusy = false

        // Проверка почты
        group.enter()
        Auth.auth().fetchSignInMethods(forEmail: data.email) { signInMethods, error in
            if let error = error {
                print("error emailIsBusy: \(error)")
            } else if signInMethods == nil {
                // почта не используется
            } else {
                emailIsBusy = true
            }
            group.leave()
        }

        // Проверка nickname
        group.enter()
        db.collection("users")
            .whereField("nickname", isEqualTo: data.nickname)
            .getDocuments() { snapshot, error in
                if let error = error {
                    print("error nicknameIsBusy: \(error)")
                    nicknameIsBusy = true
                } else {
                    nicknameIsBusy = snapshot?.documents.count ?? 0 > 0
                }
                group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            if emailIsBusy {
                completion(.emailAlreadyInUse)
            } else if nicknameIsBusy {
                completion(.nicknameAlreadyInUse)
            } else {
                // Создать нового пользователя
                Auth.auth().createUser(withEmail: data.email, password: data.password) { result, error in
                    if error != nil {
                        completion(.error)
                    } else if let result = result {
                        let userUid = result.user.uid
                        let email = data.email
                        let nickname = data.nickname
                        let avatarURL = data.avatarURL
                        let data: [String: Any] = ["email": email, "nickname": nickname, "avatarURL": avatarURL ?? ""]
                        self.db.collection("users").document(userUid).setData(data) { error in
                            if error != nil {
                                completion(.error)
                            } else {
                                self.configEmail.configEmail()
                                completion(.success)
                            }
                        }
                    } else {
                        completion(.unknownError)
                    }
                }
            }
        }
    }
}

