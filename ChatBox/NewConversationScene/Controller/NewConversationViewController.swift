//
//  NewConversationViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 26/4/2023.
//

import UIKit

final class NewConversationViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupSearchBar()
        
    }
    
    //MARK - Objc methods
    @objc private func dissmissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Extension UISearchBarDelegate
extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

//MARK: - Extension UITableView
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewConversationTableViewCell.self), for: indexPath) as? NewConversationTableViewCell
        else {
            return UITableViewCell()
        }

        return cell
    }
    
    
}

//MARK: - Private Extension
private extension NewConversationViewController {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: String(describing: NewConversationTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: NewConversationTableViewCell.self))
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
}
