//
//  ChatListTableViewCell.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 10/4/2023.
//

import UIKit
import SDWebImage

class ChatListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userIconImageView: UIImageView!
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
        userIconImageView.makeRounded()
        
    }
    
    func configureChatListCell(items: ChatListModel) {
        nameLabel.text = items.username
        messageLabel.text = items.lastMessage
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        dateLabel.text = dateFormatter.string(from: items.date as Date)
    }
    
    func configureImageCell(items: String) {
        guard let url = URL(string: items) else { return }
        userIconImageView.sd_setImage(with: url) { [weak self] (image, error, cacheType, url) in
            guard let self = self else { return }
            if let error = error {
                print("Failed to load image with error: \(error.localizedDescription)")
            } else {
                DispatchQueue.global(qos: .userInitiated).async {
                    let resizedImage = image?.sd_resizedImage(with: CGSize(width: 50, height: 50), scaleMode: .aspectFill)
                    SDImageCache.shared.store(resizedImage, forKey: url?.absoluteString)
                    DispatchQueue.main.async {
                        self.userIconImageView.image = resizedImage
                    }
                }
            }
        }
    }
}
