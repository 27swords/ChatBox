//
//  CustomRefreshControl.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 2/3/2023.
//

import UIKit

final class CustomRefreshControl: UIRefreshControl {
    
    private let loadingSpinner = UIActivityIndicatorView(style: .medium)
    private let messageLabel = UILabel()
    
    override init() {
        super.init()
        
        loadingSpinner.color = .gray
        messageLabel.text = "Потяните, чтобы обновить"
        messageLabel.font = UIFont.systemFont(ofSize: 12)
        messageLabel.textColor = .gray
        
        addSubview(loadingSpinner)
        addSubview(messageLabel)
        
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: loadingSpinner.bottomAnchor, constant: 8)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()
        loadingSpinner.startAnimating()
        messageLabel.text = "Загрузка..."
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        loadingSpinner.stopAnimating()
        messageLabel.text = "Потяните, чтобы обновить"
    }
    
}
