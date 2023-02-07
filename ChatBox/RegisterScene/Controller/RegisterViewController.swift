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
    @IBOutlet weak var backgroundImage: UIImageView!
    
    //MARK: - Inits
    var delegate: StartViewControllerDelegate?
    var checkFields = CheckFields.shared
    var serviceUser = FireBaseService.shared
    var checkError = CheckErrors.shared
        
    //MARK: - Aсtions
    @IBAction func closeRegisterAction(_ sender: Any) {
        delegate?.closeVC()
    }
    
    @IBAction func regButtonAction(_ sender: Any) {
        
        let tabBarVC = TabBarViewController()
        let loginField = LoginModel(email: emailTextField.text!, password: passTextField.text!)
        
        //проверка Email
        if checkFields.isValidEmail(emailTextField.text ?? "") && passTextField.text == repPassTextField.text {
            serviceUser.createNewUser(loginField) { [weak self] code in
                switch code.code {
                case 0:
                    print("Ошибка регистрации")
                case 1:
                    self?.view.insertSubview(tabBarVC.view, belowSubview: tabBarVC.view)
                    self?.serviceUser.configEmail()
                default:
                    print("неизвестная ошибка")
                    
                }
            }
        } else {
            errorEmail.isHidden = false
        }
        
        //проверка паролей на отличия
        if passTextField.text == repPassTextField.text {
            differentPass.isHidden = true
        } else {
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



