//
//  ChatListTableViewCell.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 10/4/2023.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.makeRounded()
        
    }
    
//    func configureChatListCell(items: Conversation) {
//        nameLabel.text = items
//    }
    
}
