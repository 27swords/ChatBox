//
//  AuthViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 30/1/2023.
//

import UIKit

final class AuthViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: - Inits
    weak var delegate: StartViewControllerDelegate?
    lazy var authService = AuthModel()
    lazy var checkFields = CheckFields()
    var userDefault = UserDefaults.standard

    //MARK: - IBActions
    @IBAction func closeAuthAction(_ sender: Any) {
        delegate?.closeVC()
    }
    
    @IBAction func logInChat(_ sender: Any) {
        loginChat() 
    }
        
    //MARK: - Methods
    //скрытие клавиатуры по тапу
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

private extension AuthViewController {
    private func loginChat() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        let loginField = LoginModel(email: email, password: password, nickname: email)
        
        if email.isEmpty && password.isEmpty  {
            print("Email or passwords is Empty")
            loginErrorLabel.isHidden = false
            loginErrorLabel.twitching(duration: 0.5)
            return
        }

        if !checkFields.isValidEmail(email)  {
            print("Error Email")
            loginErrorLabel.isHidden = false
            loginErrorLabel.twitching(duration: 0.5)
            return
        }

        if !checkFields.isPasswordValid(password) {
            print("Error Password")
            loginErrorLabel.isHidden = false
            loginErrorLabel.twitching(duration: 0.5)
            return
        }
        
        if checkFields.isValidEmail(email) {
            authService.authInApp(loginField) { [weak self] response in
                switch response {
                    
                case .success:
                    print("success")
                    self?.userDefault.set(true, forKey: "isLogin")
                    self?.delegate?.openChat()
                    
                case .errorAccountNotVerified:
                    print("errorAccountNotVerified")
                    self?.showAlert()
                    
                case .errorLogin:
                    print("errorLogin")
                    self?.loginErrorLabel.isHidden = false
                    self?.loginErrorLabel.twitching(duration: 0.5)
                                        
                case .error:
                    print("error")
                    self?.loginErrorLabel.isHidden = false
                    self?.loginErrorLabel.twitching(duration: 0.5)
                }
            }
        }
    }

    private func showAlert() {
        let title = "Активация"
        let message = "Вы не активировали почту! Вам выслано повторное письмо Активации"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertButton = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(alertButton)
        present(alert, animated: true)
    }
}
