//
//  ChatListViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 31/1/2023.
//

import UIKit

final class ChatListViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
}

//MARK: - TableView Extension
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatTableViewCell.self), for: indexPath) as? ChatTableViewCell
        else {
            return UITableViewCell()
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
                // Выполнеение трудоемкую операцию (например, загрузку изображения) в фоновом потоке
               
                DispatchQueue.main.async {
                    // Обновите пользовательский интерфейс в главном потоке
                }
            }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatViewController()
        vc.chatID = "firstChatId"
        vc.otherID = "IboDi5em77cvDRuvRG5AtJo7p8b2"
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - Private Extension
private extension ChatListViewController {
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: String(describing: ChatTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ChatTableViewCell.self))
    }
}
