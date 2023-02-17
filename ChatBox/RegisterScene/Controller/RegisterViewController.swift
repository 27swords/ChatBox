//
//  RegisterViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 30/1/2023.
//

import UIKit

final class RegisterViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorEmail: UILabel!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var repPassTextField: UITextField!
    @IBOutlet weak var errorPassword: UILabel!
    
    //MARK: - Inits
    weak var delegate: StartViewControllerDelegate?
    lazy var checkFields = CheckFields()
    lazy var serviceUser = RegisterService()
        
    //MARK: - Actions
    @IBAction func closeRegisterAction(_ sender: Any) {
        delegate?.closeVC()
    }
  
    @IBAction func regButtonAction(_ sender: Any) {
        createUser()
    }
    
    //MARK: - Methods
    //Скрытие клавиатуры при нажатии
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

private extension RegisterViewController {
    
    // Регистрация пользователя и проверка входных данных
    private func createUser() {
        let email = emailTextField.text ?? ""
        let password = passTextField.text ?? ""
        let repPassword = repPassTextField.text ?? ""
        
        errorEmail.text = nil
        errorPassword.text = nil
        
        if password.isEmpty && email.isEmpty  {
            errorEmail.text = "Поля не должны быть пустые"
            errorEmail.twitching(duration: 0.5)
            return
        }
        
        if !checkFields.isValidEmail(email) {
            print("E-mail Invalid")
            errorEmail.text = "Неверный E-mail"
            errorEmail.twitching(duration: 0.5)
            return
        }
        
        if password != repPassword {
            print("passwords don't match")
            errorPassword.text = "Пароли не совпадают"
            errorPassword.twitching(duration: 0.5)
            return
        }

        if !checkFields.isPasswordValid(password) {
            print("the password is too simple")
            errorPassword.text = "Пароль слишком простой"
            errorPassword.twitching(duration: 0.5)
            return
        }
                
        let data = LoginModel(email: email, password: password)
        serviceUser.createNewUser(data) { [weak self] response in
            switch response {
            case .success:
                print("Success")
                self?.showAlert()
                self?.delegate?.openAuthVC()
                
            case .alreadyInUse:
                print("already In Use")
                self?.errorEmail.text = "E-mail уже используется"
                self?.errorEmail.twitching(duration: 0.5)
                
            case .error:
                print("Error")
                self?.errorEmail.text = "Ошибка регистрации"
                self?.errorEmail.twitching(duration: 0.5)
            }
        }
    }
    
    private func showAlert() {
        let title = "Активация"
        let message = "На ваш электронный адрес было отправлено письмо с активацией!"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertButton = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(alertButton)
        present(alert, animated: true)
    }
}
