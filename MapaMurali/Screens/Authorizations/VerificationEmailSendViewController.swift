//
//  VerificationEmailSendViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 28/12/2022.
//

import UIKit
import RxSwift
import FirebaseAuth

class VerificationEmailSendViewController: UIViewController {
    
    //MARK: - Properties
    private let loginManager: LoginManager
    private let databaseManager: DatabaseManager
    
    private var disposeBag = DisposeBag()
    
    private let titleLabel = MMTitleLabel(textAlignment: .center, fontSize: 25)
    private let mailImageView = UIImageView()
    private let bodyMessage = MMBodyLabel(textAlignment: .center)
    private let openMailButton = MMFilledButton(foregroundColor: .white, backgroundColor: MMColors.violetDark, title: "Otwórz skrzynkę")
    private let linkNotArriveLabel = MMBodyLabel(textAlignment: .left)
    private let resendEmailButton = MMFilledButton(foregroundColor: .white, backgroundColor: MMColors.violetLight, title: "Wyślij link ponownie")
    
    
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
    
    
    //MARK: - Live Cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMagicLinkSubscriber()
        confiureViewController()
        configureUIElements()
        layoutUI()
    }
    
    //MARK: - Set up
    private func confiureViewController() {
        view.backgroundColor = MMColors.orangeDark
    }
    
    
    private func configureUIElements() {
        titleLabel.text = "Zweryfikuj swoje konto"
        titleLabel.textColor = MMColors.violetDark
        
        bodyMessage.text = "Na Twój email podany podczas rejestracji wysłaliśmy link aktywacyjny. Otwórz skrzynkę pocztową, znajdz mail od nas i kliknij w link, aby dokończyć rejestrację. Jeśli nie widzisz maila sprawdź folder ze spamem."
        bodyMessage.textColor = MMColors.violetDark
        bodyMessage.numberOfLines = 5
        
        linkNotArriveLabel.text = "Link nie dotarł?"
        linkNotArriveLabel.textColor = MMColors.violetLight
        
        configureMailImage()
        configureButtons()
        
    }
    
    private func configureMailImage() {
        var config = UIImage.SymbolConfiguration(paletteColors: [MMColors.violetDark])
        config = config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 80.0)))

        mailImageView.image = UIImage(systemName: "envelope.open.fill", withConfiguration: config)
    }
    
    
    private func configureButtons() {
        openMailButton.addTarget(self, action: #selector(openMailApp), for: .touchUpInside)
        resendEmailButton.addTarget(self, action: #selector(resendVerificationMail), for: .touchUpInside)
    }
    
    
    private func layoutUI() {
        mailImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(titleLabel, mailImageView, bodyMessage, openMailButton, linkNotArriveLabel, resendEmailButton)
        
        let horizontalPadding: CGFloat = 20
        
        [titleLabel, bodyMessage, openMailButton, resendEmailButton, linkNotArriveLabel].forEach { element in
            element.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding).isActive = true
            element.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding).isActive = true
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            mailImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            mailImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mailImageView.heightAnchor.constraint(equalToConstant: 100),
            mailImageView.widthAnchor.constraint(equalToConstant: 100),
            
            bodyMessage.topAnchor.constraint(equalTo: mailImageView.bottomAnchor, constant: 30),
            bodyMessage.heightAnchor.constraint(equalToConstant: 100),
            
            openMailButton.topAnchor.constraint(equalTo: bodyMessage.bottomAnchor, constant: 30),
            openMailButton.heightAnchor.constraint(equalToConstant: 50),
            
            resendEmailButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            resendEmailButton.heightAnchor.constraint(equalToConstant: 50),
            
            linkNotArriveLabel.bottomAnchor.constraint(equalTo: resendEmailButton.topAnchor, constant: -10),
            linkNotArriveLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    
    //MARK: - Actions
    @objc private func openMailApp() {
        if let url = URL(string: "message://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                presentMMAlert(message: MMMessages.couldNotOpenMail)
            }
        }
    }
    
    @objc private func resendVerificationMail() {
        guard let user = Auth.auth().currentUser else {
            presentMMAlert(message: MMMessages.defaultMessage)
            return
        }
        loginManager.sendVerificationMailTo(email: user.email!)
    }
    
    //MARK: - Biding
    private func addMagicLinkSubscriber() {
        loginManager.recivedMagicLink
            .subscribe(onNext: { [weak self] link in
                guard let self = self else { return }
                let destVC = CompleteUserDetailsViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
                destVC.modalPresentationStyle = .fullScreen
                destVC.navigationController?.isNavigationBarHidden = true
                self.present(destVC, animated: false)
            })
            .disposed(by: disposeBag)
    }
}
