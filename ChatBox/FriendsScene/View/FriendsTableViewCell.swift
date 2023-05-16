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
