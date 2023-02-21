//
//  FriendsTableViewCell.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 1/2/2023.
//

import UIKit

final class FriendsTableViewCell: UITableViewCell {

    //MARK: - Oultelts
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
    
    //MARK: - LifeCycle
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
    
    //MARK: - Methods
    func cunfigureCell(users: String) {
        userNameLabel.text = users
    }
}
