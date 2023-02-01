//
//  MMMostActivUsersCell.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 05/11/2022.
//

import UIKit

class MMMostActivUsersCell: UITableViewCell {

    static let identifier = "MMMostActivUsersCell"
    private let usernameWithAvatar = MMUsernameWithAvatarView(imageHeight: 40)
    private let userAddedMuralsCounter = MMTitleLabel(textAlignment: .right, fontSize: 20)
    
    
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Set up
    func set(user: User) {
        usernameWithAvatar.username.text = user.displayName
        usernameWithAvatar.avatarView.setImage(from: user.avatarURL, userID: user.id, uiImageSize: CGSize(width: 40, height: 40))
        userAddedMuralsCounter.text = "\(user.muralsAdded)"
    }
    
    
    private func configure() {
        contentView.addSubviews(usernameWithAvatar, userAddedMuralsCounter)
        contentView.backgroundColor = .secondarySystemBackground
        
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            usernameWithAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usernameWithAvatar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            usernameWithAvatar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -100),
            usernameWithAvatar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            userAddedMuralsCounter.centerYAnchor.constraint(equalTo: usernameWithAvatar.centerYAnchor),
            userAddedMuralsCounter.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            userAddedMuralsCounter.leadingAnchor.constraint(equalTo: usernameWithAvatar.trailingAnchor, constant: 20)
        ])
    }
}
