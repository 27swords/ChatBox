//
//  SearchUserViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 27/4/2023.
//

import UIKit
import SDWebImage

final class SearchUserViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Inits
    lazy var service = SearchUserService()
    lazy var users = [DTO]()
    
    //MARK: - Outlets
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        
        Task { @MainActor in
            await getUsers()
        }
    }
    
    //MARK: - @objc methods
    @objc private func dissmissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Extension UITableViewDelegate, UITableViewDataSource
extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchUsersTableViewCell.self), for: indexPath) as? SearchUsersTableViewCell
        else {
            return UITableViewCell()
        }
        let usersCell = users[indexPath.row]
        
        DispatchQueue.global(qos: .userInitiated).async {
            cell.configureImagecell(items: usersCell.userIconURL)
            
            DispatchQueue.main.async {
                cell.configureTextCell(items: usersCell)
                cell.users = usersCell
            }
            
            Task { @MainActor in
                do {
                    let isSubscribed = try await self.service.checkIfUserIsSubscribed(user: usersCell)
                    cell.isSubscribed = isSubscribed
                    cell.updateSubscribeButtonStatus()
                } catch {
                    
                }
            }
        }
        return cell
    }
}

//MARK: - Extension UISearchBarDelegate
extension SearchUserViewController: UISearchBarDelegate {
    
}

//MARK: - Private Extension
private extension SearchUserViewController {
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: String(describing: SearchUsersTableViewCell.self), bundle: nil),
                                   forCellReuseIdentifier: String(describing: SearchUsersTableViewCell.self))
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Закрыть",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dissmissSelf))
    }
    
    private func getUsers() async {
        do {
            let user = try await service.getUsersList()
            self.users = user
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error getUsers", error.localizedDescription)
        }
    }
}
