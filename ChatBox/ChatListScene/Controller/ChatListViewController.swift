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
    
    //MARK: - Views
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK: - Inits
    lazy var service = ChatListService()
    lazy var chats = [ChatListModel]()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationItems()
        
        Task { @MainActor in
            await fetchConversations()
        }
    }
    
    //MARK: - Objc Methods
    @objc func refresh(sender: UIRefreshControl) {
        Task { @MainActor in
            await fetchConversations()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                sender.endRefreshing()
            }
        }
    }
    
    @objc private func didtapComposeButton() {
        let vc = NewConversationViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}

//MARK: - Extension UITableView
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatListTableViewCell.self), for: indexPath) as? ChatListTableViewCell
        else {
            return UITableViewCell()
        }
        let convoCell = chats[indexPath.row]
        
        DispatchQueue.global(qos: .userInitiated).async {
            cell.cunfigureImageCell(users: convoCell.userIconURL ?? "")
            
            DispatchQueue.main.async {
                cell.configureChatListCell(items: convoCell)
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFriend = chats[indexPath.row]
        let vc = ChatViewController()
    
        vc.otherID = selectedFriend.otherId
        vc.title = selectedFriend.username
        vc.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Private Exntension
private extension ChatListViewController {
    private func setupNavigationItems() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(didtapComposeButton)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(refreshControl)
        tableView.register(UINib(nibName: String(describing: ChatListTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ChatListTableViewCell.self))
    }
    
    private func fetchConversations() async {
        do {
            let chats = try await service.getConversations()
            self.chats = chats
            self.chats.sort(by: { $0.date > $1.date })
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("error", error.localizedDescription)
        }
    }
}
