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
    private lazy var refreshControl: CustomRefreshControl = {
        let refreshControl = CustomRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK: - Inits
    lazy var service = FriendsService()
    var friend = [FriendsModel]()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        Task { @MainActor in
            await getFriend()
        }
    }
    
    //MARK: - Objc Methods
    @objc func refresh(sender: CustomRefreshControl) {
        Task { @MainActor in
            await self.getFriend()
            self.tableView.reloadData()
            sender.endRefreshing()
        }
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
            cell.cunfigureImageCell(users: friendCell.avatarURL ?? "")
               
                DispatchQueue.main.async {
                    cell.cunfigureTextCell(users: friendCell.nickname)
                }
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatViewController()
        let friendId = friend[indexPath.row].id
        vc.otherID = friendId
        
        navigationController?.pushViewController(vc, animated: true)
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
    
    private func getFriend() async {
        do {
            let friends = try await service.getUsersList()
            self.friend = friends
            tableView.reloadData()
        } catch {
            print("error", error.localizedDescription)
        }
    }
}


