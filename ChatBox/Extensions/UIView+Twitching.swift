//
//  UIView+Twitching.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 13/2/2023.
//

import UIKit
 
extension UIView {
    
    func twitching(duration: Double) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.values = [-5, 5, -5, 5, 0]
        layer.add(animation, forKey: "twitch")
    }
}




