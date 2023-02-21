//
//  StartViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 28/1/2023.
//

import UIKit

protocol StartViewControllerDelegate: AnyObject {
    func openRegisterVC()
    func openAuthVC()
    func closeVC()
    func openChat()
}


class StartViewController: UIViewController {
    
    weak var delegate: StartViewControllerDelegate?
    lazy var authVC = AuthViewController()
    lazy var registerVC = RegisterViewController()
    lazy var tabBarVC = TabBarViewController()
                
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
        self.view.addSubview(registerVC.view)
    }
    
    func openAuthVC() {
        self.view.addSubview(authVC.view)
    }
    
    func openChat() {
        let navController = UINavigationController(rootViewController: tabBarVC)
        self.view.addSubview(navController.view)
        authVC.view.removeFromSuperview()
        delegate = nil  
    }



    func closeVC() {
        authVC.view.removeFromSuperview()
        registerVC.view.removeFromSuperview()
    }
}


