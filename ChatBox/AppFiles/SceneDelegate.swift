//
//  SceneDelegate.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 28/1/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let userDefault = UserDefaults.standard

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)

        let isLogin = userDefault.object(forKey: "isLogin") as? Bool ?? false

        if isLogin == true {
            startApp()
        } else {
            startLogin()
        }
    }

    func startApp() {
        let appVC = TabBarViewController()
        if let window = window {
            window.rootViewController = appVC
            window.makeKeyAndVisible()
        }
    }

    func startLogin() {
        let startVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "StartViewController")
        if let window = window {
            window.rootViewController = startVC
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

}

