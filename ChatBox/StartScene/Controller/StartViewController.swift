//
//  StartViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 28/1/2023.
//

import UIKit

protocol StartViewControllerDelegate {
    func openRegisterVC()
    func openAuthVC()
    func closeVC()
}

class StartViewController: UIViewController {
    
    var delegate: StartViewControllerDelegate?
    var authVC = AuthViewController()
    var registerVC = RegisterViewController()
                
    //MARK: - IBActions
   @IBAction func pushRegister(_ sender: Any) {
       delegate?.openRegisterVC()
    }

    @IBAction func pushLogin(_ sender: Any) {
        delegate?.openAuthVC()
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        registerVC.delegate = self
        authVC.delegate = self
    }
}

extension StartViewController: StartViewControllerDelegate {
    func openRegisterVC() {
       self.view.insertSubview(registerVC.view, belowSubview: registerVC.view)
    }
    
    func openAuthVC() {
        self.view.insertSubview(authVC.view, belowSubview: authVC.view)
    }
    
    func closeVC() {
        authVC.view.removeFromSuperview()
        registerVC.view.removeFromSuperview()
    }
}

