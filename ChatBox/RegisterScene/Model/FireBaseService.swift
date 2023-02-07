//
//  FireBaseService.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 6/2/2023.
//

import UIKit
import Firebase

final class FireBaseService {
    
    //MARK: - Singleton
    static let shared = FireBaseService()
    init() {}
    
    //MARK: - Methods
    func createNewUser(_ data: LoginModel, completion: @escaping (ResponseCodeModel) -> ()) {
        Auth.auth().createUser(withEmail: data.email, password: data.password) { [weak self] result, error in
            if error == nil {
                if result != nil {
//                    let userId = result?.user.uid
                    completion(ResponseCodeModel(code: 1))
                }
            } else {
                completion(ResponseCodeModel(code: 0))
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
