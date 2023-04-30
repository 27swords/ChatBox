//
//  SearchFiendsTableViewCell.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 27/4/2023.
//

import UIKit

final class SearchFiendsTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    
    //MARK: - Propierties
    lazy var service = SearchFriendsService()
    var friend: DTO?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.makeRounded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func addFriendButtonTapped(_ sender: Any) {
        print("addFriendButtonTapped called")
        Task { @MainActor in
            await addFriend()
        }
    }
    
    func cunfigureTextCell(users: String) {
        emailLabel.text = users
    }
    
    func cunfigureImageCell(users: String) {
        avatarImageView.sd_setImage(with: URL(string: users))
    }
    
    private func addFriend() async {
        
        guard let friend = self.friend else { return }
        
        do {
            try await service.subscribeToFriend(friendID: friend.id)
            // Show success message to user
        } catch {
            print("error", error.localizedDescription)
            // Show error message to user
        }
        print("Friends", friend)
    }
}
