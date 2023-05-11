//
//  FriendsTableViewCell.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 1/2/2023.
//

import UIKit
import SDWebImage

final class FriendsTableViewCell: UITableViewCell {

    //MARK: - Oultelts
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIconImageView: UIImageView!
    
    
    //MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userIconImageView.makeRounded()
    }
    
    //MARK: - Methods
    func cunfigureTextCell(users: String) {
        userNameLabel.text = users
    }
    
    func cunfigureImageCell(users: String) {
        userIconImageView.sd_setImage(with: URL(string: users))
    }
}
