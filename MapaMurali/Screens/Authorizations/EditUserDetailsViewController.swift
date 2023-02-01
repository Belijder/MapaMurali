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
        titleLabel.text = "Edytuj informacje"
        callToActionButton.setTitle("Uaktualnij", for: .normal)
    }
    
    
    //MARK: - Actions
    override func callToActionButtonTapped() {
        print("🟡 Update Data button tapped.")
        showLoadingView(message: "Uakualnianie informacji")
        
        guard let avatarData = avatarImage else {
            dismissLoadingView()
            presentMMAlert(title: "Dodaj avatar", message: "Dodaj avatar do swojego konta.", buttonTitle: "Ok")
            return
        }
        
        guard let nickname = nickNameTextField.text,
              nickname.count > 2 else {
            dismissLoadingView()
            presentMMAlert(title: "Zbyt krótko!", message: "Nazwa użytkownika musi posiadać minimum trzy znaki.", buttonTitle: "Ok")
            return
        }
        
        guard let userID = databaseManager.currentUser?.id else {
            dismissLoadingView()
            presentMMAlert(title: "Ups", message: "Coś poszło nie tak. Nie udało się edytować informacji. Spróbuj ponownie za chwilę.", buttonTitle: "Ok")
            return
        }
        
        var data = [String : Any]()
        data["displayName"] = self.nickNameTextField.text
        
        
        self.databaseManager.updateUserData(id: userID, data: data, avatarImageData: avatarData) { success in
            if success {
                if let image = self.avatarImageView.image {
                    PersistenceManager.instance.saveImage(image: image, imageType: .avatar, name: userID)
                }
                print("🟢 User data was successfully update.")
                
                self.databaseManager.currentUser?.displayName = nickname
                
                if self.databaseManager.users.contains(where: { $0.id ==  userID }) {
                    if let index = self.databaseManager.users.firstIndex(where: { $0.id == userID }) {
                        self.databaseManager.users[index].displayName = nickname
                    }
                }
                
                self.dismissLoadingView()
                self.navigationController?.popViewController(animated: true)
            } else {
                self.presentMMAlert(title: "Ups", message: "Coś poszło nie tak. Nie udało się edytować informacji. Spróbuj ponownie za chwilę.", buttonTitle: "Ok")
            }
        }
    }
}
