//
//  MMEmptyStateView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 05/01/2023.
//

import UIKit

class MMEmptyStateView: UIView {
    
    //MARK: - Properties
    private let messageLabel = MMTitleLabel(textAlignment: .center, fontSize: 20)
    private let signetImageView = UIImageView()
    
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    convenience init(message: String) {
        self.init(frame: .zero)
        messageLabel.text = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Set up
    private func configure() {
        addSubviews(messageLabel, signetImageView)
        configureMessageLabel()
        configureSignetImageView()
    }
    
    
    private func configureMessageLabel() {
        messageLabel.numberOfLines = 4
        messageLabel.textColor = .secondaryLabel
        
        NSLayoutConstraint.activate([
            messageLabel.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 100),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            messageLabel.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    
    private func configureSignetImageView() {
        signetImageView.image = MMImages.mmSignet
        signetImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signetImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            signetImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 100),
            signetImageView.widthAnchor.constraint(equalToConstant: 195),
            signetImageView.heightAnchor.constraint(equalToConstant: 210)
        ])
    }
}
