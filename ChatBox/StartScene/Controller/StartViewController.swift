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

final class StartViewController: UIViewController {
    
    //MARK: - Inits
    weak var delegate: StartViewControllerDelegate?
    lazy var authVC = AuthViewController()
    lazy var registerVC = RegisterViewController()
                
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

//MARK: - extension StartViewControllerDelegate
extension StartViewController: StartViewControllerDelegate {
    
    ///transition animation
    func fadeAnimation() {
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = .fade
        self.view.window?.layer.add(transition, forKey: kCATransition)
    }
    
    ///opening the registration View
    func openRegisterVC() {
        fadeAnimation()
        self.view.addSubview(registerVC.view)
    }
    
    ///openinng the auth View
    func openAuthVC() {
        fadeAnimation()
        self.view.addSubview(authVC.view)
    }
    
    ///auth in chat
    func openChat() {
        let tabBarVC = TabBarViewController()

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        window.rootViewController = tabBarVC
    }

    ///exit from view
    func closeVC() {
        fadeAnimation()
        authVC.view.removeFromSuperview()
        registerVC.view.removeFromSuperview()
    }
}


