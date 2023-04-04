//
//  EditUserDetailsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 01/02/2023.
//

import UIKit

class EditUserDetailsViewController: CompleteUserDetailsViewController {

    //MARK: - Initialization
    init(avatar: UIImage?, nickname: String, databaseManager: DatabaseManager, loginManager: LoginManager) {
        super.init(loginManager: loginManager, databaseManager: databaseManager)
        
        if let image = avatar {
            let resizedImage = image.aspectFittedToHeight(120)
            let circleImage = resizedImage.cropImageToCircle()
            avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2.0
            avatarImageView.image = circleImage
            avatarImage = avatar?.jpegData(compressionQuality: 1.0)
        }
        nickNameTextField.text = nickname
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = MMColors.violetDark
        titleLabel.text = "Edytuj informacje"
        callToActionButton.setTitle("Uaktualnij", for: .normal)
    }
    
    
    //MARK: - Actions
    override func callToActionButtonTapped() {
        guard NetworkMonitor.shared.isConnected == true else {
            presentMMAlert(title: "Brak połączenia", message: MMError.noConnectionDefaultMessage.rawValue)
            return
        }
        
        showLoadingView(message: "Uakualnianie informacji")
        
        guard let avatarData = avatarImage else {
            dismissLoadingView()
            presentMMAlert(message: MMMessages.addAvatar)
            return
        }
        
        guard let nickname = nickNameTextField.text,
              nickname.count > 2 else {
            dismissLoadingView()
            presentMMAlert(message: MMMessages.usernameToShort)
            return
        }
        
        guard let userID = databaseManager.currentUser?.id else {
            dismissLoadingView()
            presentMMAlert(message: MMMessages.unableToEditAccountInfo)
            return
        }
        
        var data = [String : Any]()
        data["displayName"] = self.nickNameTextField.text
        
        
        self.databaseManager.updateUserData(id: userID, data: data, avatarImageData: avatarData) { success in
            if success {
                if let image = self.avatarImageView.image {
                    PersistenceManager.instance.saveImage(image: image, imageType: .avatar, name: userID)
                }

                self.databaseManager.currentUser?.displayName = nickname
                
                if self.databaseManager.users.contains(where: { $0.id ==  userID }) {
                    if let index = self.databaseManager.users.firstIndex(where: { $0.id == userID }) {
                        self.databaseManager.users[index].displayName = nickname
                    }
                }
                
                self.dismissLoadingView()
                self.navigationController?.popViewController(animated: true)
            } else {
                self.presentMMAlert(message: MMMessages.unableToEditAccountInfo)
            }
        }
    }
}
