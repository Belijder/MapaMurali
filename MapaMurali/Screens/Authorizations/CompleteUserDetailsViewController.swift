//
//  CompleteUserDetailsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 17/12/2022.
//

import UIKit
import RxSwift

class CompleteUserDetailsViewController: UIViewController {
    
    //MARK: - Properties
    
    let loginManager: LoginManager
    let databaseManager: DatabaseManager
    var bag = DisposeBag()
    
    private let avatarImageView = MMAvatarImageView(frame: .zero)
    private let nickNameTextField = MMTextField(placeholder: "nazwa użytkownika", type: .custom)
    private let callToActionButton = MMTintedButton(color: MMColors.primary, title: "Zaczynamy!")
    
    var avatarImage: Data?
    
    
    //MARK: - Initialization
    
    init(loginManager: LoginManager, databaseManager: DatabaseManager) {
        self.loginManager = loginManager
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Live cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureUIElements()
        layoutUI()
        addSingInObserver()
        
    }
    
    override func viewDidLayoutSubviews() {
        nickNameTextField.styleTextFieldWithBottomBorder(color: MMColors.primary)
    }
    
    //MARK: - Set up
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Uzupełnij informacje"
    }
    
    func configureUIElements() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tap)
        
        callToActionButton.addTarget(self, action: #selector(callToActionButtonTapped), for: .touchUpInside)
    }
    
    func layoutUI() {
        view.addSubviews(avatarImageView, nickNameTextField, callToActionButton)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            
            nickNameTextField.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: padding),
            nickNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            nickNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            nickNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            
            callToActionButton.topAnchor.constraint(equalTo: nickNameTextField.bottomAnchor, constant: padding),
            callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            callToActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            callToActionButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    
    //MARK: - Logic
    
    //MARK: - Actions
    
    @objc func avatarImageViewTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Zrób zdjęcie", style: .default) { _ in self.actionSheetCameraButtonTapped() })
        actionSheet.addAction(UIAlertAction(title: "Wybierz z galerii", style: .default) { _ in self.actionSheetLibraryButtonTapped() })
        actionSheet.addAction(UIAlertAction(title: "Wróć", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    
    func actionSheetCameraButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true)
        }
    }
    
    
    func actionSheetLibraryButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true)
        }
    }
    
    @objc func callToActionButtonTapped() {
        
        guard let email = UserDefaults.standard.object(forKey: Setup.kEmail) as? String else { return }
        print("🟠 email from UserDefault is: \(email)")
        
        guard let avatarData = avatarImage else {
            presentMMAlert(title: "Dodaj avatar", message: "Dodaj avatar do swojego konta.", buttonTitle: "Ok")
            return
        }
        
        guard let userID = loginManager.currentUserID else {
            presentMMAlert(title: "Ups", message: "Coś poszło nie tak. Nie udało się utworzyć konta. Spróbuj ponownie za chwilę.", buttonTitle: "Ok")
            return
        }
        
            var userData = [String : Any]()
            userData["id"] = userID
            userData["displayName"] = self.nickNameTextField.text
            userData["email"] = email
            userData["muralsAdded"] = 0
            userData["favoritesMurals"] = [String]()
            
        self.databaseManager.addNewUserToDatabase(id: userID, userData: userData, avatarImageData: avatarData) { success in
            if success {
                self.loginManager.userIsLoggedIn.onNext(true)
            }
        }
        
    }
    
    
    //MARK: - Bindings
    func addSingInObserver() {
        loginManager.userIsLoggedIn
            .subscribe(onNext: { value in
                if value == true {
                    self.view.window?.rootViewController?.dismiss(animated: true)
                }
            })
            .disposed(by: bag)
    }
}

//MARK: - Extensions
extension CompleteUserDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        let resizedImage = image?.aspectFittedToHeight(120)
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2.0
        avatarImageView.image = resizedImage
        avatarImage = image?.jpegData(compressionQuality: 0.3)
        
        self.dismiss(animated: true)
    }
}


