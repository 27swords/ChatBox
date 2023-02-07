//
//  FriendsTableViewCell.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 1/2/2023.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        avatarImage.makeRounded()
        self.contentView.layoutIfNeeded()
    }
    
}
