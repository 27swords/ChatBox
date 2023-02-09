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
    var delegate: StartViewControllerDelegate?
    var checkFields = CheckFields()
    var serviceUser = RegisterService()
        
    //MARK: - Aсtions
    @IBAction func closeRegisterAction(_ sender: Any) {
        delegate?.closeVC()
    }
  
    @IBAction func regButtonAction(_ sender: Any) {
        createUser()
    }


    //MARK: - LIfeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Methods
    //скрытие клавиатуры по тапу 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

//MARK: - Private Extension
private extension RegisterViewController {
    // регистрация пользователя и проверка ввода данных
    private func createUser() {
        let tabBarVC = TabBarViewController()
        let email = emailTextField.text ?? ""
        let password = passTextField.text ?? ""
        let repPassword = repPassTextField.text ?? ""

        if !checkFields.isValidEmail(email) {
            errorEmail.text = "Неверный E-mail"
            return
        }

        if password != repPassword {
            errorPassword.text = "Пароли не совпадают"
            return
        }
        
        if !checkFields.isPasswordValid(password) {
            errorPassword.text = "Слишком простой пароль"
            return
        }

        let data = LoginModel(email: email, password: password)
        serviceUser.createNewUser(data) { [weak self] response in
            switch response {
            case .success:
                let alert = UIAlertController(title: "Активация", message: "На вашу почту отправлено письмо активации!", preferredStyle: .alert)
                let alertButton = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(alertButton)
                self?.present(alert, animated: true)
                
                self?.view.insertSubview(tabBarVC.view, belowSubview: tabBarVC.view)
                
            case .alreadyInUse:
                self?.errorEmail.text = "E-mail уже используется"
                
            case .error:
                self?.errorEmail.text = "Ошибка Регистрации"
                print("ERROR EMAIL")
            }
        }
    }
}
