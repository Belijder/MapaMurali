//
//  CompleteUserDetailsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 17/12/2022.
//

import UIKit
import RxSwift
import Photos

class CompleteUserDetailsViewController: MMDataLoadingVC {
    
    //MARK: - Properties
    private let loginManager: LoginManager
    private let databaseManager: DatabaseManager
    private var disposeBag = DisposeBag()
    
    private let titleLabel = MMTitleLabel(textAlignment: .left, fontSize: 20)
    private let avatarImageView = MMAvatarImageView(frame: .zero)
    private let nickNameTextField = MMTextField(placeholder: "nazwa użytkownika", type: .custom)
    private let callToActionButton = MMFilledButton(foregroundColor: .white, backgroundColor: MMColors.violetDark, title: "Zaczynamy!")
    
    private var avatarImage: Data?
    
    
    //MARK: - Initialization
    init(loginManager: LoginManager, databaseManager: DatabaseManager) {
        self.loginManager = loginManager
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = DisposeBag()
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
        nickNameTextField.styleTextFieldWithBottomBorder(color: MMColors.violetDark)
    }
    
    
    //MARK: - Set up
    private func configureViewController() {
        view.backgroundColor = MMColors.orangeDark
    }
    
    
    private func configureUIElements() {
        titleLabel.text = "Uzupełnij informacje"
        titleLabel.textColor = MMColors.violetDark
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tap)
        
        callToActionButton.addTarget(self, action: #selector(callToActionButtonTapped), for: .touchUpInside)
    }
    
    private func layoutUI() {
        view.addSubviews(titleLabel, avatarImageView, nickNameTextField, callToActionButton)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            avatarImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
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
    
    
    //MARK: - Actions
    @objc private func avatarImageViewTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Zrób zdjęcie", style: .default) { _ in self.actionSheetCameraButtonTapped() })
        actionSheet.addAction(UIAlertAction(title: "Wybierz z galerii", style: .default) { _ in self.actionSheetLibraryButtonTapped() })
        actionSheet.addAction(UIAlertAction(title: "Wróć", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    
    private func actionSheetCameraButtonTapped() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            showLoadingView(message: "Uzyskiwanie dostępu do aparatu...")
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            imagePickerController.showsCameraControls = true
            self.present(imagePickerController, animated: true, completion: self.dismissLoadingView)
        case .denied, .restricted:
            presentMMAlert(title: "Brak dostępu", message: "Aby zrobić zdjęcie musisz wyrazić zgodę na używanie aparatu. Przejdź do Ustawienia > Mapa Murali i wyraź zgodę na używanie aparatu.", buttonTitle: "Ok")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("Access granted")
                    DispatchQueue.main.async {
                        self.showLoadingView(message: "Uzyskiwanie dostępu do aparatu...")
                        let imagePickerController = UIImagePickerController()
                        imagePickerController.delegate = self
                        imagePickerController.sourceType = .camera
                        imagePickerController.showsCameraControls = true
                        self.present(imagePickerController, animated: true, completion: self.dismissLoadingView)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.presentMMAlert(title: "Brak dostępu", message: "Aby zrobić zdjęcie musisz wyrazić zgodę na używanie aparatu. Przejdź do Ustawienia > Mapa Murali i wyraź zgodę na używanie aparatu.", buttonTitle: "Ok")
                    }
                }
            }
        @unknown default:
            break
        }
    }
    
    
    private func actionSheetLibraryButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true)
        }
    }
    
    @objc private func callToActionButtonTapped() {
        showLoadingView(message: "Uakualnianie informacji")
        
        guard let email = UserDefaults.standard.object(forKey: Setup.kEmail) as? String else { return }
        
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
        
        guard let userID = loginManager.currentUserID else {
            dismissLoadingView()
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
                try? self.databaseManager.fetchCurrenUserData()
                self.loginManager.userIsLoggedIn.onNext(true)
                self.dismissLoadingView()
            }
        }
    }
    
    
    //MARK: - Bindings
    private func addSingInObserver() {
        loginManager.userIsLoggedIn
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                if value == true {
                    self.view.window?.rootViewController?.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)
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


