//
//  UserAccountViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 30/07/2022.
//

import UIKit
import MessageUI

class UserAccountViewController: UIViewController {
    
    //MARK: - Properties
    var loginManager: LoginManager
    let databaseManager: DatabaseManager
    
    var userAddedMurals = [Mural]()
    var userFavoriteMurals = [Mural]()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let usernameAndAvatar = MMUsernameWithAvatarView(imageHeight: 100)
    
    let userAddedMuralsCollectionView = UIView()
    let userFavoriteMuralsCollectionView = UIView()
    
    let rateAppButton = MMFilledButton(foregroundColor: MMColors.secondary, backgroundColor: .secondarySystemBackground, title: "Oceń aplikację!")
    let sendMessageButton = MMFilledButton(foregroundColor: MMColors.secondary, backgroundColor: .secondarySystemBackground, title: "Napisz do nas!")
    let showTermOfUseButton = MMFilledButton(foregroundColor: MMColors.secondary, backgroundColor: .secondarySystemBackground, title: "Regulamin")
    let showPrivacyPolicyButton = MMFilledButton(foregroundColor: MMColors.secondary, backgroundColor: .secondarySystemBackground, title: "Polityka Prywatności")
    let logOutButton = MMFilledButton(foregroundColor: .white, backgroundColor: .systemRed, title: "Wyloguj się")
    let deleteAccountAndDataButton = MMPlainButton(color: .systemRed, title: "Usuń konto i dane")

    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Moje konto"
    
        
        setupScrollView()
        configureUsernameAndAvatarView()
        configureCollectionsViews()
        configureButtons()
        layoutUI()

        sendMessageButton.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        deleteAccountAndDataButton.addTarget(self, action: #selector(deleteAcconutButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Set up
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.pinToEdges(of: view)
        scrollView.showsVerticalScrollIndicator = false
        contentView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 930)
        ])
    }
    
    func configureUsernameAndAvatarView() {
        guard let userID = loginManager.currentUserID else { return }
        databaseManager.fetchUserFromDatabase(id: userID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.usernameAndAvatar.username.text = user.displayName
                    self.usernameAndAvatar.avatarView.setImage(from: user.avatarURL)
                case .failure(let error):
                    print("🔴 Error to fetch users info from Database. Error: \(error)")
                    self.usernameAndAvatar.username.text = "brak nazwy"
                }
            }
        }
        
        self.usernameAndAvatar.username.font = UIFont.systemFont(ofSize: 30, weight: .bold)
    }
    
    func configureCollectionsViews() {
        add(childVC: MMUserAddedMuralsCollectionsVC(collectionName: "Dodane przez Ciebie",
                                                    murals: [],
                                                    databaseManager: databaseManager), to: self.userAddedMuralsCollectionView)
            
        add(childVC: MMUserFavoritesMuralsCollectionVC(colectionName: "Twoje ulubione murale",
                                                       murals: [],
                                                       databaseManager: databaseManager), to: userFavoriteMuralsCollectionView)
    }
    
    func configureButtons() {
        showTermOfUseButton.addTarget(self, action: #selector(showTermOfUse), for: .touchUpInside)
        showPrivacyPolicyButton.addTarget(self, action: #selector(showPrivacyPolicy), for: .touchUpInside)
    }
    
    func layoutUI() {
        contentView.addSubviews(usernameAndAvatar, userAddedMuralsCollectionView, userFavoriteMuralsCollectionView, rateAppButton, sendMessageButton, showTermOfUseButton, showPrivacyPolicyButton, logOutButton, deleteAccountAndDataButton)
        
        userAddedMuralsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        userFavoriteMuralsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let allbuttons = [rateAppButton, sendMessageButton, showTermOfUseButton, showPrivacyPolicyButton, logOutButton, deleteAccountAndDataButton]

        let padding: CGFloat = 20
        let betweenButtonPadding: CGFloat = 10
        let sectionPadding: CGFloat = 30
        
        for button in allbuttons {
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
                button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
                button.heightAnchor.constraint(equalToConstant: 50),
            ])
        }
        
        NSLayoutConstraint.activate([
            usernameAndAvatar.topAnchor.constraint(equalTo: contentView.topAnchor),
            usernameAndAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            usernameAndAvatar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            usernameAndAvatar.heightAnchor.constraint(equalToConstant: 100),
            
            userAddedMuralsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            userAddedMuralsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            userAddedMuralsCollectionView.topAnchor.constraint(equalTo: usernameAndAvatar.bottomAnchor, constant: sectionPadding),
            userAddedMuralsCollectionView.heightAnchor.constraint(equalToConstant: 170),
            
            userFavoriteMuralsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            userFavoriteMuralsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            userFavoriteMuralsCollectionView.topAnchor.constraint(equalTo: userAddedMuralsCollectionView.bottomAnchor, constant: sectionPadding),
            userFavoriteMuralsCollectionView.heightAnchor.constraint(equalToConstant: 170),
            
            rateAppButton.topAnchor.constraint(equalTo: userFavoriteMuralsCollectionView.bottomAnchor, constant: sectionPadding),
            sendMessageButton.topAnchor.constraint(equalTo: rateAppButton.bottomAnchor, constant: betweenButtonPadding),
            showTermOfUseButton.topAnchor.constraint(equalTo: sendMessageButton.bottomAnchor, constant: sectionPadding),
            showPrivacyPolicyButton.topAnchor.constraint(equalTo: showTermOfUseButton.bottomAnchor, constant: betweenButtonPadding),
            logOutButton.topAnchor.constraint(equalTo: showPrivacyPolicyButton.bottomAnchor, constant: sectionPadding),
            deleteAccountAndDataButton.topAnchor.constraint(equalTo: logOutButton.bottomAnchor, constant: betweenButtonPadding)
        ])
    }
    
    //MARK: - Logic
    @objc func logOut() {
        loginManager.singOut()
        presentLoginScreen()
    }
    
    func presentLoginScreen() {
        let vc = SingInViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: false)
    }
    
    @objc func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["mapamurali@gmail.com"])
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            presentMMAlert(title: "Nie można wysłać maila", message: "Sprawdź czy masz skonfugurowanego klienta pocztowego i spróbuj ponownie. ", buttonTitle: "Ok")
        }
    }
    
    @objc func showTermOfUse() {
        databaseManager.fetchLegalTerms { result in
            switch result {
            case.success(let terms):
                guard let url = URL(string: terms.termOfUse) else {
                    self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: MMError.failedToGetLegalTerms.rawValue, buttonTitle: "Ok")
                    return
                }
                self.presentSafariVC(with: url)
            case .failure(let error):
                self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    @objc func showPrivacyPolicy() {
        databaseManager.fetchLegalTerms { result in
            switch result {
            case.success(let terms):
                guard let url = URL(string: terms.privacyPolicy) else {
                    self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: MMError.failedToGetLegalTerms.rawValue, buttonTitle: "Ok")
                    return
                }
                self.presentSafariVC(with: url)
            case .failure(let error):
                self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    func deleteAcountAndData(password: String) {
        print("🟡 Delete account button in alert tapped.")
        loginManager.deleteAccount(password: password) { result in
            switch result {
            case .success(let userID):
                self.databaseManager.removeAllUserData(userID: userID) { result in
                    switch result {
                    case .success(_):
                        print("🟢 All user data was removed from database.")
                        self.presentLoginScreen()
                    case .failure(let error):
                        print(error.rawValue)
                        self.presentLoginScreen()
                    }
                }
            case .failure(let error):
                self.presentMMAlert(title: "Ups!", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    @objc private func deleteAcconutButtonTapped() {
        let alert = UIAlertController(title: "Usuń konto!",
                                      message: "Aby potwierdzić usunięcie konta oraz wszystkich związanych z nim danych, podaj hasło używane do zalogowania się do aplikacji. Pamiętej, że tej operacji nie będzie można cofnąć.",
                                      preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = "Hasło"
            field.clearButtonMode = .unlessEditing
            field.returnKeyType = .continue
            field.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cofnij", style: .cancel))
        alert.addAction(UIAlertAction(title: "Potwierdź", style: .destructive) { _ in
            guard let password = alert.textFields![0].text else {
                return
            }
            print("Password in alert: \(password)")
            self.deleteAcountAndData(password: password)
            
        })
        
        present(alert, animated: true)
        
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    //MARK: - Initialization
    init(loginManager: LoginManager, databaseManager: DatabaseManager) {
        self.loginManager = loginManager
        self.databaseManager = databaseManager
        if databaseManager.currentUser == nil { databaseManager.fetchCurrenUserData() }
        super.init(nibName: nil, bundle: nil) 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

//MARK: - Extensions
extension UserAccountViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
