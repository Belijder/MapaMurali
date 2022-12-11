//
//  SingUpViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 04/08/2022.
//

import UIKit
import RxSwift

class SingUpViewController: UIViewController {
    
    //MARK: - Properties
    let loginManager: LoginManager
    let databaseManager: DatabaseManager
    var bag = DisposeBag()
    
    var avatarImage: Data?
    private let avatarImageView = MMAvatarImageView(frame: .zero)
    private let removeImageButton = MMCircleButton(color: .label, systemImageName: "xmark")
    private let nickNameTextField = MMTextField(placeholder: "nazwa użytkownika", type: .custom)
    private let emailTextField = MMTextField(placeholder: "e-mail", type: .email)
    private let passwordTextField = MMTextField(placeholder: "hasło", type: .password)
    private let singUpButton = MMTintedButton(color: MMColors.primary, title: "Zarejestruj się!")

    
    //MARK: - Inicialization
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
        view.backgroundColor = .systemBackground
        view.addSubviews(avatarImageView, nickNameTextField, emailTextField, passwordTextField, singUpButton)
        configureUIElements()
        layoutUI()
        addSingInObserver()
    }
    
    override func viewDidLayoutSubviews() {
        emailTextField.styleTextFieldWithBottomBorder(color: MMColors.primary)
        passwordTextField.styleTextFieldWithBottomBorder(color: MMColors.primary)
        nickNameTextField.styleTextFieldWithBottomBorder(color: MMColors.primary)
    }
    
    
    //MARK: - Set up
    func configureUIElements() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tap)
        
        singUpButton.addTarget(self, action: #selector(singUpButtonTapped), for: .touchUpInside)
        
    }
    
    
    func layoutUI() {
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
            
            emailTextField.topAnchor.constraint(equalTo: nickNameTextField.bottomAnchor, constant: padding),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: padding),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            singUpButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            singUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            singUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            singUpButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    //MARK: - Actions
    @objc func singUpButtonTapped() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let avatarData = avatarImage else { return }
        
//        loginManager.singUp(email: email, password: password) { [weak self] userID in
//            guard let self = self else { return }
//
//            var userData = [String : Any]()
//            userData["id"] = userID
//            userData["displayName"] = self.nickNameTextField.text
//            userData["email"] = email
//            userData["muralsAdded"] = 0
//            userData["favoritesMurals"] = [String]()
//
//            self.databaseManager.addNewUserToDatabase(id: userID, userData: userData, avatarImageData: avatarData)
//        }
        
        loginManager.singUpWithMailVerification(email: email)
    }
    
    
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
    
    
    @objc func returnToSingInView(sender: UIButton!) {
        self.dismiss(animated: true)
    }
    
    
    //MARK: - Binding
    func addSingInObserver() {
        loginManager.userIsLoggedIn
            .subscribe(onNext: { value in
                if value == true {
                    self.navigationController?.dismiss(animated: true)
                }
            })
            .disposed(by: bag)
    }
}

//MARK: - Extensions
extension SingUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        let resizedImage = image?.aspectFittedToHeight(120)
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2.0
        avatarImageView.image = resizedImage
        avatarImage = image?.jpegData(compressionQuality: 0.3)
        
        self.dismiss(animated: true)
    }
}
