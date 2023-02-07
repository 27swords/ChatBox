//
//  ChatListViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 31/1/2023.
//

import UIKit

final class ChatListViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatTableViewCell.self), for: indexPath) as? ChatTableViewCell
        else {
            return UITableViewCell()
        }
        return cell
    }
    
    
}

private extension ChatListViewController {
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: String(describing: ChatTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ChatTableViewCell.self))
    }
}
