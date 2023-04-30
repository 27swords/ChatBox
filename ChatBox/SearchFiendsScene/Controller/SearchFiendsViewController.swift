//
//  SearchFiendsViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 27/4/2023.
//

import UIKit

final class SearchFiendsViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Propierties
    lazy var service = SearchFriendsService()
    var friend = [DTO]()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        
        Task { @MainActor in
            await getFriend()
        }
    }
    
    //MARK: - Objc methods
    @objc private func dissmissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Extension UITableViewDelegate
extension SearchFiendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friend.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchFiendsTableViewCell.self), for: indexPath) as? SearchFiendsTableViewCell
        else {
            return UITableViewCell()
        }
        
        let friendCell = friend[indexPath.row]
        
        DispatchQueue.global(qos: .userInitiated).async {
            cell.cunfigureImageCell(users: friendCell.avatarURL ?? "")
            
            DispatchQueue.main.async {
                cell.cunfigureTextCell(users: friendCell.nickname)
                cell.friend = friendCell
            }
        }
        return cell
    }
}

//MARK: - Extension UISearchBarDelegate
extension SearchFiendsViewController: UISearchBarDelegate {
    
}

//MARK: - Private Exntension
private extension SearchFiendsViewController {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: String(describing: SearchFiendsTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: SearchFiendsTableViewCell.self))
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Закрыть",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dissmissSelf))
    }
    
    private func getFriend() async {
        do {
            let friends = try await service.getFriendsList()
            self.friend = friends
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("error", error.localizedDescription)
        }
    }
}
