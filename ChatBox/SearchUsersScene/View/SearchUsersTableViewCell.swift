//
//  SearchUsersTableViewCell.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 10/5/2023.
//

import UIKit
import SDWebImage

final class SearchUsersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var userIconImageView: UIImageView!
    
    lazy var service = SearchUserService()
    var users: DTO?
    var isSubscribed: Bool = false

    
    @IBAction func subscribeUsersAction(_ sender: Any) {
        Task { @MainActor in
            await subscribeToUsers()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userIconImageView.makeRounded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureTextCell(items: DTO) {
        usernameLabel.text = items.username
        users = items
        updateSubscribeButtonStatus()
    }
    
    func configureImagecell(items: String) {
        userIconImageView.sd_setImage(with: URL(string: items))
    }
    
    func updateSubscribeButtonStatus() {
        let color: UIColor = isSubscribed ? .systemGray : .blue
        let title: String = isSubscribed ? "Вы подписаны" : "Подписаться"
        subscribeButton.tintColor = color
        subscribeButton.setTitle(title, for: .normal)
    }
}

private extension SearchUsersTableViewCell {
    private func subscribeToUsers() async {
        guard let user = self.users else { return }
        
        do {
            try await service.subscribeToUsers(userId: user.id)
            isSubscribed = true
            updateSubscribeButtonStatus()
        } catch {
            print("Error subscribeToUsers", error.localizedDescription)
        }
    }
}
