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
    @IBOutlet weak var differentPass: UILabel!
    
    //MARK: - Inits
    var delegate: StartViewControllerDelegate?
    var checkFields = CheckFields.shared
    var serviceUser = RegisterModel.shared
        
    //MARK: - Aсtions
    @IBAction func closeRegisterAction(_ sender: Any) {
        delegate?.closeVC()
    }
    
    @IBAction func regButtonAction(_ sender: Any) {
        let tabBarVC = TabBarViewController()
        let email = emailTextField.text ?? ""
        let password = passTextField.text ?? ""
        let data = LoginModel(email: email, password: password)
        
        switch (checkFields.isValidEmail(email), password == repPassTextField.text) {
        case (true, true):
            serviceUser.createNewUser(data) { [weak self] response in
                switch response {
        
                case .success:
                    let alert = UIAlertController(title: "Активация", message: "На вашу почту отправлено письмо активации!", preferredStyle: .alert)
                    let alertButton = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(alertButton)
                    self?.present(alert, animated: true)
                    
                    self?.view.insertSubview(tabBarVC.view, belowSubview: tabBarVC.view)
                    self?.serviceUser.configEmail()

                case .alreadyInUse:
                    print("Почта уже существует")
                    
                case .error:
                    print("Ошибка регистрации")
                }
            }
        case (false, _):
            errorEmail.text = "Неверный E-mail"
            
        default:
            differentPass.isHidden = false
        }
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
