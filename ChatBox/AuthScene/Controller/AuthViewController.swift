//
//  AuthViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 30/1/2023.
//

import UIKit

final class AuthViewController: UIViewController {
    
    //MARK: - Inits
    var delegate: StartViewControllerDelegate?

    //MARK: - IBActions
    @IBAction func closeAuthAction(_ sender: Any) {
        delegate?.closeVC()
    }
    
    @IBAction func logInChat(_ sender: Any) {
        let tabBarVC = TabBarViewController()
        self.view.insertSubview(tabBarVC.view, belowSubview: tabBarVC.view)
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
