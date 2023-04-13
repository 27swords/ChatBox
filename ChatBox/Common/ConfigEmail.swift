//
//  ConfigEmail.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 13/2/2023.
//

import Foundation
import Firebase

class ConfigEmail {
    
    //потверждение email
    func configEmail() {
        DispatchQueue.global(qos: .userInitiated).async {
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("error configEmail: \(error)")
                    }
                }
            })
        }
    }
}
 
