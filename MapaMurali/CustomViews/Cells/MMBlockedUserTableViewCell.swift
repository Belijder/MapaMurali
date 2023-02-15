//
//  BlockedUserTableViewCell.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 14/02/2023.
//

import UIKit

protocol MMBlockedUserCellDelegate: AnyObject {
    func unblockButtonTappedFor(userID: String)
}

class MMBlockedUserTableViewCell: UITableViewCell {
    
    static let identifier = "MMBlockedUserTableViewCell"
    
    private var userID: String?
    weak var delegate: MMBlockedUserCellDelegate?
    
    private let usernameAndAvatar = MMUsernameWithAvatarView(imageHeight: 60)
    private let unblockButton = MMFilledButton(foregroundColor: .white, backgroundColor: MMColors.primary, title: "Odblokuj")
    
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    //MARK: - Set up
    private func configure() {
        contentView.backgroundColor = .systemBackground
        contentView.addSubviews(usernameAndAvatar, unblockButton)
        
        unblockButton.addTarget(self, action: #selector(unblockButtonTapped), for: .touchUpInside)
        
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            usernameAndAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            usernameAndAvatar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            usernameAndAvatar.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 50),
            usernameAndAvatar.heightAnchor.constraint(equalToConstant: 60),
            
            unblockButton.centerYAnchor.constraint(equalTo: usernameAndAvatar.centerYAnchor),
            unblockButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            unblockButton.heightAnchor.constraint(equalToConstant: 44),
            unblockButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    
    func set(from user: User) {
        usernameAndAvatar.avatarView.setImage(from: user.avatarURL, userID: user.id, uiImageSize: CGSize(width: 60, height: 60))
        usernameAndAvatar.username.text = user.displayName
        userID = user.id
    }
    
    
    // MARK: - Actions
    @objc func unblockButtonTapped() {
        guard let id = userID else { return }
        delegate?.unblockButtonTappedFor(userID: id)
    }
}
