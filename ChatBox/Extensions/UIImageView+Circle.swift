//
//  UIImageView+Circle.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 1/2/2023.
//

import UIKit

extension UIView {
    
    // Создание круглой иконки
    func makeRounded() {
        layer.borderWidth = 1
        layer.masksToBounds = false
        layer.borderColor = UIColor.clear.cgColor
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
}
