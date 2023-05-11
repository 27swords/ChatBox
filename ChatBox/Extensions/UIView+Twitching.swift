//
//  UIView+Twitching.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 13/2/2023.
//

import UIKit
 
extension UIView {
    
    func twitching() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.5
        animation.values = [-5, 5, -5, 5, 0]
        layer.add(animation, forKey: "twitch")
    }
    
    /// Creating a round view
    public func makeRounded() {
        layer.borderWidth = 1
        layer.masksToBounds = false
        layer.borderColor = UIColor.clear.cgColor
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
}




