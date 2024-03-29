//
//  UsernameWithAvatarView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 15/10/2022.
//

import UIKit

class MMUsernameWithAvatarView: UIView {
    
    //MARK: - Properties
    let avatarView = MMAvatarImageView(frame: .zero)
    let username = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(imageHeight: CGFloat) {
        self.init(frame: .zero)
        configure(imageHeight: imageHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Set up
    func configure(imageHeight: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(avatarView, username)
        
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: self.topAnchor),
            avatarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: imageHeight),
            avatarView.heightAnchor.constraint(equalToConstant: imageHeight),
            
            username.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            username.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10),
            username.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            username.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
