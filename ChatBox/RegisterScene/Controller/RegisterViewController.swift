//
//  RegisterViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 30/1/2023.
//

import UIKit
import MBProgressHUD

final class RegisterViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorEmail: UILabel!
    @IBOutlet weak var errorNicknameLabel: UILabel!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var repPassTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var errorPassword: UILabel!
    
    //MARK: - Inits
    weak var delegate: StartViewControllerDelegate?
    lazy var checkFields = CheckFields()
    lazy var service = RegisterService()
        
    //MARK: - IBAction
    @IBAction func closeRegisterAction(_ sender: Any) {
        delegate?.closeVC()
        hiddingOutlets()
    }
    
    @IBAction func regButtonAction(_ sender: Any) {
        Task { @MainActor in
            await createUser()
        }
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        nicknameTextField.autocorrectionType = .no
        emailTextField.autocorrectionType = .no
    }
    
    //MARK: - Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

//MARK: - Private Extension
private extension RegisterViewController {

    //User registration and verification of input data
    private func createUser() async {
        guard let email = emailTextField.text else { return }
        guard let username = nicknameTextField.text else { return }
        guard let password = passTextField.text else { return }
        guard let repPassword = repPassTextField.text else { return }

        let data = DTO(id: "", email: email, password: password, username: username, userIconURL: "")
            
        if password.isEmpty && email.isEmpty  {
            errorEmail.text = "Поля не должны быть пустые"
            errorEmail.twitching()
            return
        }

        if !checkFields.isValidEmail(email) {
            print("E-mail Invalid")
            errorEmail.text = "Неверный E-mail"
            errorEmail.twitching()
            return
        }

        if password != repPassword {
            print("passwords don't match")
            errorPassword.text = "Пароли не совпадают"
            errorPassword.twitching()
            return
        }

        if !checkFields.isPasswordValid(password) {
            print("the password is too simple")
            errorPassword.text = "Пароль слишком простой"
            errorPassword.twitching()
            return
        }
        
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Регистрация..."
        }

        await service.createNewUser(data) { [weak self] response in
            guard let self = self else { return }

            switch response {
            case .success:
                print("Success")
                DispatchQueue.main.async {
                    self.showAlert()
                    self.delegate?.openAuthVC()
                    self.hiddingOutlets()
                }
            case .emailAlreadyInUse:
                print("already In Use")
                DispatchQueue.main.async {
                    self.errorEmail.text = "E-mail уже используется"
                    self.errorEmail.twitching()
                }
            case .error:
                print("Error")
                DispatchQueue.main.async {
                    self.showErrorAlert()
                }
            case .usernameAlreadyInUse:
                DispatchQueue.main.async {
                    self.errorNicknameLabel.text = "Имя пользователя занято"
                    self.errorNicknameLabel.twitching()
                }
            case .unknownError:
                print("unknownError")
            }
            self.hideHud()
        }
    }
    
    ///hiding the loading indicator
    private func hideHud() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    ///clearing all fields and labels after exiting the view
    private func hiddingOutlets() {
        emailTextField.text = nil
        nicknameTextField.text = nil
        passTextField.text = nil
        repPassTextField.text = nil
        
        errorNicknameLabel.text = ""
        errorEmail.text = ""
        errorPassword.text = ""
    }
    
    
    ///alert about successful registration
    private func showAlert() {
        Task { @MainActor in
            let title = "Активация"
            let message = "На ваш электронный адрес было отправлено письмо с активацией!"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let alertButton = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(alertButton)
            present(alert, animated: true)
        }
    }
    
    ///alert of registration error
    private func showErrorAlert() {
        Task { @MainActor in
            let title = "Ошибка"
            let message = "Неизвестная ошибка"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let alertButton = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(alertButton)
            present(alert, animated: true)
        }
    }
}
