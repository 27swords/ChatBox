//
//  FriendsViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 1/2/2023.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage

final class FriendsViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Views
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK: - Inits
    lazy var service = FriendsService()
    lazy var friend = [DTO]()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationItems()
        Task { @MainActor in
            await getFriend()
        }
    }
    
    //MARK: - Objc Methods
    @objc func refresh(sender: UIRefreshControl) {
        Task { @MainActor in
            await getFriend()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                sender.endRefreshing()
            }
        }
    }
    
    @objc private func didtapComposeButton() {
        let vc = SearchUserViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}

//MARK: - TableView extension
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friend.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FriendsTableViewCell.self), for: indexPath) as? FriendsTableViewCell
        else {
            return UITableViewCell()
        }
        
        let friendCell = friend[indexPath.row]
        
        DispatchQueue.global(qos: .userInitiated).async {
            cell.configureImageCell(items: friendCell.userIconURL)
                DispatchQueue.main.async {
                    cell.cunfigureTextCell(users: friendCell.username)
                }
            }
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let letters = Set(friend.compactMap { $0.username.first?.uppercased() })
        return letters.sorted()
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return friend.firstIndex { $0.username.hasPrefix(title) } ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFriend = friend[indexPath.row]
        let vc = ChatViewController()
    
        vc.otherID = selectedFriend.id
        vc.title = selectedFriend.username
        vc.otherUserIconImage = selectedFriend.userIconURL
        vc.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(vc, animated: true)
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let friend = self.friend[indexPath.row]
        
        let action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, completionHandler) in
            Task { @MainActor in
                do {
                    try await self.service.deleteFriends(friendID: friend.id)
                    self.friend.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } catch {
                    print("Failed to delete friend: \(error.localizedDescription)")
                }
                completionHandler(true)
            }
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}

//MARK: - Private Extension
private extension FriendsViewController {
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.addSubview(refreshControl)
        tableView.register(UINib(nibName: String(describing: FriendsTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: FriendsTableViewCell.self))
    }
    
    private func setupNavigationItems() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didtapComposeButton)
        )
    }
    
    ///display a list of friends in the view
    private func getFriend() async {
        do {
            let friends = try await service.getFriendsList()
            self.friend = friends.sorted(by: { $0.username < $1.username })
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("error", error.localizedDescription)
        }
    }
}


