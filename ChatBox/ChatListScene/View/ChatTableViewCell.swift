//
//  ChatTableViewCell.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 31/1/2023.
//

import UIKit

final class ChatTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var newMessengeView: UIView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        avatarImage.makeRounded()
        newMessengeView.makeRounded()
        self.contentView.layoutIfNeeded()
    }
}
