//
//  TabBarViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 31/1/2023.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        makeTabItems()
    }
}

private extension TabBarViewController {
    func setupTabBar() {
        tabBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tabBar.backgroundColor = #colorLiteral(red: 1, green: 0.9999999404, blue: 0.9999999404, alpha: 1)
        tabBar.unselectedItemTintColor = .gray
    }
    
    func makeTabItems() {
        let friends = FriendsViewController()
        let user = UserViewController()
        
        guard let friendsIcon = UIImage(systemName: "person.2") else { return }
        guard let userIcon = UIImage(systemName: "person") else { return }
        
        let friendsScene = createNavController(for: friends, title: "Друзья", image: friendsIcon)
        let userScene = createNavController(for: user, title: "Профиль", image: userIcon)

        viewControllers = [friendsScene, userScene]
    }
    
    func createNavController(for rootViewController: UIViewController,
                             title: String,
                             image: UIImage?)
    -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        rootViewController.navigationItem.title = title
        navController.navigationBar.tintColor = .black
        return navController
    }
}
