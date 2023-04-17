//
//  ChatListViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 10/4/2023.
//

import UIKit

final class ChatListViewController: UIViewController {

    //MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    //MARK: - Objc Methods
    @objc func refresh(sender: UIRefreshControl) {
        Task { @MainActor in
            
            self.tableView.reloadData()
            sender.endRefreshing()
        }
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatListTableViewCell.self), for: indexPath) as? ChatListTableViewCell
        else {
            return UITableViewCell()
        }

        return cell
    }
}

private extension ChatListViewController {
    private func setupTableView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(refreshControl)
        tableView.register(UINib(nibName: String(describing: ChatListTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ChatListTableViewCell.self))
    }
}
