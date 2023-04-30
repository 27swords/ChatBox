//
//  AuthViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 30/1/2023.
//

import UIKit
import MBProgressHUD

final class AuthViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: - Inits
    weak var delegate: StartViewControllerDelegate?
    lazy var service = AuthService()
    lazy var checkFields = CheckFields()
    var userDefault = UserDefaults.standard

    //MARK: - IBActions
    @IBAction func closeAuthAction(_ sender: Any) {
        delegate?.closeVC()
        
        emailTextField.text = nil
        passwordTextField.text = nil
        loginErrorLabel.isHidden = true
    }
    
    @IBAction func logInChat(_ sender: Any) {
        Task { @MainActor in
            await loginChat()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.autocorrectionType = .no
    }
        
    //MARK: - Methods
    //скрытие клавиатуры по тапу
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

private extension AuthViewController {
    private func loginChat() async {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        let loginField = DTO(id: "", email: email, password: password, nickname: email, avatarURL: "")
        
        if email.isEmpty && password.isEmpty  {
            print("Email or passwords is Empty")
            loginErrorLabel.isHidden = false
            loginErrorLabel.twitching()
            return
        }
        
        if !checkFields.isValidEmail(email)  {
            print("Error Email")
            loginErrorLabel.isHidden = false
            loginErrorLabel.twitching()
            return
        }
        
        if !checkFields.isPasswordValid(password) {
            print("Error Password")
            loginErrorLabel.isHidden = false
            loginErrorLabel.twitching()
            return
        }
        
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Вход..."
        }
        
        if checkFields.isValidEmail(email) {
            do {
                let response = try await service.authInApp(loginField)
                switch response {
                    
                case .success:
                    self.userDefault.set(true, forKey: "isLogin")
                    self.delegate?.openChat()
                case .errorAccountNotVerified:
                    self.showAlert()
                case .errorLogin:
                    self.loginErrorLabel.isHidden = false
                    self.loginErrorLabel.twitching()
                case .error:
                    self.loginErrorLabel.isHidden = false
                    self.loginErrorLabel.twitching()
                }
            } catch {
                print("Error:", error.localizedDescription)
            }
            self.hideHud()
        }
    }
    
    private func hideHud() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    private func showAlert() {
        Task { @MainActor in
            let title = "Активация"
            let message = "Вы не активировали почту! Вам выслано повторное письмо Активации"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let alertButton = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(alertButton)
            present(alert, animated: true)
        }
    }
}
