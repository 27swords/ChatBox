//
//  ChatListTableViewCell.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 10/4/2023.
//

import UIKit
import SDWebImage

class ChatListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
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
    
    func configureChatListCell(items: ChatListModel) {
        nameLabel.text = items.nickname
        messageLabel.text = items.lastMessage
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        dateLabel.text = dateFormatter.string(from: items.date as Date)
    }
    
    func cunfigureImageCell(users: String) {
        avatarImageView.sd_setImage(with: URL(string: users))
    }
}
