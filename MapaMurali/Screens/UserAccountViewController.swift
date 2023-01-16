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

class UserAccountViewController: MMDataLoadingVC {
    
    //MARK: - Properties
    var loginManager: LoginManager
    let databaseManager: DatabaseManager
    
    var disposeBag = DisposeBag()
    
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
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Moje konto"
        
        addUserLoginObserver()
        addCurrentUserSubscriber()
        
        setupScrollView()
        configureButtons()
        layoutUI()
        configureCollectionsViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUsernameAndAvatarView()
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
            contentView.heightAnchor.constraint(equalToConstant: 940)
        ])
    }
    
    func configureUsernameAndAvatarView() {
        self.usernameAndAvatar.username.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        guard let user = databaseManager.currentUser else {
            databaseManager.fetchCurrenUserData()
            return
        }
        
        self.usernameAndAvatar.username.text = user.displayName
        self.usernameAndAvatar.avatarView.setImage(from: user.avatarURL, userID: user.id)
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
        rateAppButton.addTarget(self, action: #selector(rateAppButtonTapped), for: .touchUpInside)
        
        sendMessageButton.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        deleteAccountAndDataButton.addTarget(self, action: #selector(deleteAcconutButtonTapped), for: .touchUpInside)
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
            userAddedMuralsCollectionView.topAnchor.constraint(equalTo: usernameAndAvatar.bottomAnchor, constant: 20),
            userAddedMuralsCollectionView.heightAnchor.constraint(equalToConstant: 170),
            
            userFavoriteMuralsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            userFavoriteMuralsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            userFavoriteMuralsCollectionView.topAnchor.constraint(equalTo: userAddedMuralsCollectionView.bottomAnchor, constant: 25),
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
        let destVC = SingInViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
        destVC.modalPresentationStyle = .fullScreen
        destVC.navigationController?.navigationBar.tintColor = MMColors.primary
        present(destVC, animated: false)
    }
    
    func deleteAcountAndData(password: String) {
        showLoadingView(message: "Trwa usuwanie konta")
        print("🟡 Delete account button in alert tapped.")
        loginManager.deleteAccount(password: password) { result in
            switch result {
            case .success(let userID):
                self.databaseManager.removeAllUserData(userID: userID) { result in
                    switch result {
                    case .success(_):
                        print("🟢 All user data was removed from database. This should be last print.")
                        print("Current user is: \(Auth.auth().currentUser?.uid)")
                        self.loginManager.userIsLoggedIn.onNext(false)
                        self.dismissLoadingView()
                    case .failure(let error):
                        print("🔴 Error on the last step in deleting account. ERROR: \(error.rawValue)")
                        self.validateAuth()
                        self.dismissLoadingView()
                    }
                }
            case .failure(let error):
                self.presentMMAlert(title: "Ups!", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let destVC = SingInViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
            destVC.modalPresentationStyle = .fullScreen
            destVC.navigationController?.navigationBar.tintColor = MMColors.primary
            destVC.navigationController?.navigationBar.backItem?.title = "Zaloguj się"
            present(destVC, animated: false)
        } else {
            //Present VC with info about verification requirements if needed
//            if FirebaseAuth.Auth.auth().currentUser?.isEmailVerified == false {
//                let destVC = VerificationEmailSendViewController(loginManager: loginManager, databaseManager: databaseManager)
//                destVC.modalPresentationStyle = .fullScreen
//                present(destVC, animated: false)
//            }
        }
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    
    //MARK: - Actions
    
    @objc func rateAppButtonTapped() {
    
    }
    
    @objc func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["mapamurali@gmail.com"])
            mail.setMessageBody("<p>W czym możemy pomóc? :)</p>", isHTML: true)
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
    
    //MARK: - Binding
    
    func addCurrentUserSubscriber() {
        databaseManager.currentUserPublisher
            .subscribe(onNext: { user in
                self.configureUsernameAndAvatarView()
            })
            .disposed(by: disposeBag)
    }
    
    func addUserLoginObserver() {
        loginManager.userIsLoggedIn
            .subscribe(onNext: { value in
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
