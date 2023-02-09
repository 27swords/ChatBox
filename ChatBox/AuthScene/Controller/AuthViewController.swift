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
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: - Inits
    var delegate: StartViewControllerDelegate?
    var authService = AuthModel()
    var checkFields = CheckFields()

    //MARK: - IBActions
    @IBAction func closeAuthAction(_ sender: Any) {
        delegate?.closeVC()
    }
    
    @IBAction func logInChat(_ sender: Any) {
        let tabBarVC = TabBarViewController()
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let loginField = LoginModel(email: email, password: password)
        
        if checkFields.isValidEmail(email) {
            authService.authInApp(loginField) { [weak self] response in
                switch response {
                    
                case .success:
                    print("SUCCES")
                    self?.view.insertSubview(tabBarVC.view, belowSubview: tabBarVC.view)
                    
                case .notVerify:
                    print("NOT VEREFY")
                    
                case .error:
                    print("ERRRO AUTHVC")
                }
            }
        }
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Methods
    //скрытие клавиатуры по тапу
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

