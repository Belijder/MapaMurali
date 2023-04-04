//
//  UserAccountViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 30/07/2022.
//

import UIKit
import MessageUI
import RxSwift
import FirebaseAuth
import StoreKit

class UserAccountViewController: MMDataLoadingVC {
    
    //MARK: - Properties
    private let loginManager: LoginManager
    private let databaseManager: DatabaseManager
    
    private var disposeBag = DisposeBag()
    
    private var userAddedMurals = [Mural]()
    private var userFavoriteMurals = [Mural]()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let usernameAndAvatar = MMUsernameWithAvatarView(imageHeight: 100)
    private let openAdminPanelButton = MMTitleLabel(textAlignment: .right, fontSize: 14)
    
    private let userAddedMuralsCollectionView = UIView()
    private let userFavoriteMuralsCollectionView = UIView()
    
    private let blockedUsersButton = MMFilledButton(foregroundColor: MMColors.secondary, backgroundColor: .secondarySystemBackground, title: "Zablokowani użytkownicy")
    private let rateAppButton = MMFilledButton(foregroundColor: MMColors.secondary, backgroundColor: .secondarySystemBackground, title: "Oceń aplikację!")
    private let sendMessageButton = MMFilledButton(foregroundColor: MMColors.secondary, backgroundColor: .secondarySystemBackground, title: "Napisz do nas!")
    private let showTermOfUseButton = MMFilledButton(foregroundColor: MMColors.secondary, backgroundColor: .secondarySystemBackground, title: "Regulamin")
    private let showPrivacyPolicyButton = MMFilledButton(foregroundColor: MMColors.secondary, backgroundColor: .secondarySystemBackground, title: "Polityka Prywatności")
    private let logOutButton = MMFilledButton(foregroundColor: .white, backgroundColor: .systemRed, title: "Wyloguj się")
    private let deleteAccountAndDataButton = MMPlainButton(color: .systemRed, title: "Usuń konto i dane")

    
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
        
        addUserLoginObserver()
        addCurrentUserSubscriber()
        
        setupScrollView()
        configureButtons()
        layoutUI()
        configureCollectionsViews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = MMColors.orangeDark
        configureUsernameAndAvatarView()
    }
    
    
    //MARK: - Set up
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = MMColors.primary
        self.title = "Moje konto"
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = editButton
    }
    
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.pinToEdges(of: view)
        scrollView.showsVerticalScrollIndicator = false
        contentView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 1000)
        ])
    }
    
    
    private func configureUsernameAndAvatarView() {
        self.usernameAndAvatar.username.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        guard let user = databaseManager.currentUser else {
            try? databaseManager.fetchCurrenUserData() { _ in }
            return
        }
        
        self.usernameAndAvatar.username.text = user.displayName
        self.usernameAndAvatar.avatarView.setImage(from: user.avatarURL, userID: user.id, uiImageSize: CGSize(width: 100, height: 100))
        
        if user.isAdmin {
            openAdminPanelButton.alpha = 1.0
        } else {
            openAdminPanelButton.alpha = 0.0
        }
    }
    
    
    private func configureCollectionsViews() {
        add(childVC: MMUserAddedMuralsCollectionsVC(collectionName: "Dodane przez Ciebie",
                                                    murals: [],
                                                    databaseManager: databaseManager), to: self.userAddedMuralsCollectionView)
            
        add(childVC: MMUserFavoritesMuralsCollectionVC(colectionName: "Twoje ulubione murale",
                                                       murals: [],
                                                       databaseManager: databaseManager), to: userFavoriteMuralsCollectionView)
    }
    
    
    private func configureButtons() {
        openAdminPanelButton.textColor = MMColors.primary
        openAdminPanelButton.text = "Panel administratora"
        let tap = UITapGestureRecognizer(target: self, action: #selector(openAdminPanelButtonTapped))
        openAdminPanelButton.isUserInteractionEnabled = true
        openAdminPanelButton.addGestureRecognizer(tap)
        
        blockedUsersButton.addTarget(self, action: #selector(blockedUsersButtonTapped), for: .touchUpInside)
        showTermOfUseButton.addTarget(self, action: #selector(showTermOfUse), for: .touchUpInside)
        showPrivacyPolicyButton.addTarget(self, action: #selector(showPrivacyPolicy), for: .touchUpInside)
        rateAppButton.addTarget(self, action: #selector(rateAppButtonTapped), for: .touchUpInside)
        
        sendMessageButton.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        deleteAccountAndDataButton.addTarget(self, action: #selector(deleteAcconutButtonTapped), for: .touchUpInside)
    }
    
    func layoutUI() {
        contentView.addSubviews(usernameAndAvatar, userAddedMuralsCollectionView, openAdminPanelButton, userFavoriteMuralsCollectionView, blockedUsersButton, rateAppButton, sendMessageButton, showTermOfUseButton, showPrivacyPolicyButton, logOutButton, deleteAccountAndDataButton)
        
        userAddedMuralsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        userFavoriteMuralsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let allbuttons = [blockedUsersButton, rateAppButton, sendMessageButton, showTermOfUseButton, showPrivacyPolicyButton, logOutButton, deleteAccountAndDataButton]

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
            
            openAdminPanelButton.bottomAnchor.constraint(equalTo: usernameAndAvatar.bottomAnchor),
            openAdminPanelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            openAdminPanelButton.heightAnchor.constraint(equalToConstant: 20),
            openAdminPanelButton.widthAnchor.constraint(equalToConstant: 300),
            
            userAddedMuralsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            userAddedMuralsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            userAddedMuralsCollectionView.topAnchor.constraint(equalTo: usernameAndAvatar.bottomAnchor, constant: 20),
            userAddedMuralsCollectionView.heightAnchor.constraint(equalToConstant: 170),
            
            userFavoriteMuralsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            userFavoriteMuralsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            userFavoriteMuralsCollectionView.topAnchor.constraint(equalTo: userAddedMuralsCollectionView.bottomAnchor, constant: 25),
            userFavoriteMuralsCollectionView.heightAnchor.constraint(equalToConstant: 170),
            
            blockedUsersButton.topAnchor.constraint(equalTo: userFavoriteMuralsCollectionView.bottomAnchor, constant: sectionPadding),
            rateAppButton.topAnchor.constraint(equalTo: blockedUsersButton.bottomAnchor, constant: sectionPadding),
            sendMessageButton.topAnchor.constraint(equalTo: rateAppButton.bottomAnchor, constant: betweenButtonPadding),
            showTermOfUseButton.topAnchor.constraint(equalTo: sendMessageButton.bottomAnchor, constant: sectionPadding),
            showPrivacyPolicyButton.topAnchor.constraint(equalTo: showTermOfUseButton.bottomAnchor, constant: betweenButtonPadding),
            logOutButton.topAnchor.constraint(equalTo: showPrivacyPolicyButton.bottomAnchor, constant: sectionPadding),
            deleteAccountAndDataButton.topAnchor.constraint(equalTo: logOutButton.bottomAnchor, constant: betweenButtonPadding)
        ])
    }
    
    //MARK: - Logic
    @objc private func logOut() {
        loginManager.signOut()
        databaseManager.currentUser = nil
        databaseManager.murals = []
        presentLoginScreen()
    }
    
    
    private func presentLoginScreen() {
        let destVC = SignInViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
        destVC.modalPresentationStyle = .fullScreen
        destVC.navigationController?.navigationBar.tintColor = MMColors.primary
        present(destVC, animated: false)
    }
    
    
    private func deleteAcountAndData(password: String) {
        guard NetworkMonitor.shared.isConnected == true else {
            presentMMAlert(title: "Brak połączenia", message: MMError.noConnectionDefaultMessage.rawValue)
            return
        }
        
        showLoadingView(message: "Trwa usuwanie konta")

        loginManager.deleteAccount(password: password) { result in
            switch result {
            case .success(let userID):
                self.databaseManager.removeAllUserData(userID: userID) { result in
                    switch result {
                    case .success(_):
                        self.loginManager.userIsLoggedIn.onNext(false)
                        self.dismissLoadingView()
                    case .failure(_):
                        self.validateAuth()
                        self.dismissLoadingView()
                    }
                }
                PersistenceManager.instance.deleteFolderWithMuralImages()
            case .failure(let error):
                self.presentMMAlert(title: "Ups!", message: error.rawValue)
            }
        }
    }
    
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let destVC = SignInViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
            destVC.modalPresentationStyle = .fullScreen
            destVC.navigationController?.navigationBar.tintColor = MMColors.primary
            destVC.navigationController?.navigationBar.backItem?.title = "Zaloguj się"
            present(destVC, animated: false)
        }
    }
    
    
    private func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    
    //MARK: - Actions
    @objc private func openAdminPanelButtonTapped() {
        let destVC = AdminPanelViewController(databaseManager: databaseManager)
        destVC.title = "Panel administratora"
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    @objc private func editButtonTapped() {
        let destVC = EditUserDetailsViewController(avatar: usernameAndAvatar.avatarView.image,
                                                   nickname: usernameAndAvatar.username.text ?? "",
                                                   databaseManager: databaseManager,
                                                   loginManager: loginManager)
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    @objc private func blockedUsersButtonTapped() {
        let destVC = BlockedUsersVC(databaseManager: databaseManager)
        destVC.title = "Zablokowani użytkownicy"
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    @objc private func rateAppButtonTapped() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1659498483?action=write-review")
               else { fatalError("Expected a valid URL") }
           UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
    
    
    @objc private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["mapamurali@gmail.com"])
            mail.setMessageBody("<p>W czym możemy pomóc? :)</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            presentMMAlert(message: MMMessages.cannotSendMail)
        }
    }
    
    
    @objc private func showTermOfUse() {
        databaseManager.fetchLegalTerms { result in
            switch result {
            case.success(let terms):
                guard let url = URL(string: terms.termOfUse) else {
                    self.presentMMAlert(title: MMMessages.customErrorTitle, message: MMError.failedToGetLegalTerms.rawValue)
                    return
                }
                self.presentSafariVC(with: url)
            case .failure(let error):
                self.presentMMAlert(title: MMMessages.customErrorTitle, message: error.rawValue)
            }
        }
    }
    
    
    @objc private func showPrivacyPolicy() {
        databaseManager.fetchLegalTerms { result in
            switch result {
            case.success(let terms):
                guard let url = URL(string: terms.privacyPolicy) else {
                    self.presentMMAlert(title: MMMessages.customErrorTitle, message: MMError.failedToGetPolicyPrivacy.rawValue)
                    return
                }
                self.presentSafariVC(with: url)
            case .failure(let error):
                self.presentMMAlert(title: MMMessages.customErrorTitle, message: error.rawValue)
            }
        }
    }
    

    @objc private func deleteAcconutButtonTapped() {
        guard NetworkMonitor.shared.isConnected == true else {
            presentMMAlert(title: "Brak połączenia", message: MMError.noConnectionDefaultMessage.rawValue)
            return
        }
        
        let alert = UIAlertController(title: MMMessages.deletingAccount.title,
                                      message: MMMessages.deletingAccount.message,
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
            
            self.deleteAcountAndData(password: password)
            
        })
        
        present(alert, animated: true)
    }
    
    
    //MARK: - Binding
    private func addCurrentUserSubscriber() {
        databaseManager.currentUserPublisher
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                self.configureUsernameAndAvatarView()
            })
            .disposed(by: disposeBag)
    }
    
    
    private func addUserLoginObserver() {
        loginManager.userIsLoggedIn
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                if value == false {
                    self.validateAuth()
                }
            })
            .disposed(by: disposeBag)
    }
}


//MARK: - Extensions
extension UserAccountViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
