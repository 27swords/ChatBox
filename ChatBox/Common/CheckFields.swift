//
//  CheckFields.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 6/2/2023.
//

import Foundation

final class CheckFields {
    
    //MARK: - Methods
    //Проверка E-mail на валидность
    func isValidEmail(_ email: String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return emailTest.evaluate(with: email)
    }
    
    //проверка сложности пароля
    func isPasswordValid(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
        return passwordTest.evaluate(with: password)
    }

}

