//
//  FriendsViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 1/2/2023.
//

import UIKit

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
    var users = [FriendsModel]()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getUsers()
    }
    
    //MARK: - Methods
    func getUsers() {
        service.getUsersList { users in
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Objc Methods
    @objc func refresh(sender: CustomRefreshControl) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.getUsers()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                sender.endRefreshing()
            }
        }
    }
}

//MARK: - TableView extension
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FriendsTableViewCell.self), for: indexPath) as? FriendsTableViewCell
        else {
            return UITableViewCell()
        }
        
        let usersCell = users[indexPath.row]
        
        DispatchQueue.global(qos: .userInitiated).async {
                // Выполнеение трудоемкую операцию (например, загрузку изображения) в фоновом потоке
               
                DispatchQueue.main.async {
                    // Обновите пользовательский интерфейс в главном потоке
                    cell.cunfigureCell(users: usersCell.nickname)
                }
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatViewController()
        let userId = users[indexPath.row].id
        vc.otherID = userId
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Private Extension
private extension FriendsViewController {
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.addSubview(refreshControl)
        tableView.register(UINib(nibName: String(describing: FriendsTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: FriendsTableViewCell.self))
    }
}


