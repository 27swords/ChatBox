//
//  TabBarViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 31/1/2023.
//

import UIKit

final class TabBarViewController: UITabBarController {

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        makeTabItems()
    }
}

//MARK: - Private Extension
private extension TabBarViewController {
    
    ///tabBar configuration
    func setupTabBar() {
        tabBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tabBar.backgroundColor = #colorLiteral(red: 1, green: 0.9999999404, blue: 0.9999999404, alpha: 1)
        tabBar.unselectedItemTintColor = .gray
    }
    
    ///setting up cells in tabbar
    func makeTabItems() {
        let friends = FriendsViewController()
        let chatList = ChatListViewController()
        let user = ProfileViewController()
        
        guard let friendsIcon = UIImage(systemName: "person.2") else { return }
        guard let chatListIcon = UIImage(systemName: "message") else { return }
        guard let userIcon = UIImage(systemName: "person") else { return }
        
        let friendsScene = createNavController(for: friends, title: "Друзья", image: friendsIcon)
        let chatListScene = createNavController(for: chatList, title: "Сообщения", image: chatListIcon)
        let userScene = createNavController(for: user, title: "Профиль", image: userIcon)

        viewControllers = [friendsScene, chatListScene, userScene]
    }
    
    ///creating a navigationcontroller
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
