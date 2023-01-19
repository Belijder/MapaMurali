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
    
    
    //MARK: - Properties
    
    let loginManager: LoginManager
    let databaseManager: DatabaseManager
    
    var disposeBag = DisposeBag()
    
    let titleLabel = MMTitleLabel(textAlignment: .center, fontSize: 25)
    let mailImageView = UIImageView()
    let bodyMessage = MMBodyLabel(textAlignment: .center)
    let openMailButton = MMFilledButton(foregroundColor: .white, backgroundColor: MMColors.violetDark, title: "Otwórz skrzynkę")
    let linkNotArriveLabel = MMBodyLabel(textAlignment: .left)
    let resendEmailButton = MMFilledButton(foregroundColor: .white, backgroundColor: MMColors.violetLight, title: "Wyślij link ponownie")
    
    //MARK: - Live Cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMagicLinkSubscriber()
        confiureViewController()
        configureUIElements()
        layoutUI()
    }
    
    //MARK: - Set up
    
    func confiureViewController() {
        view.backgroundColor = MMColors.orangeDark
    }
    
    func configureUIElements() {
        titleLabel.text = "Zweryfikuj swoje konto"
        titleLabel.textColor = MMColors.violetDark
        
        bodyMessage.text = "Na Twój email podany podczas rejestracji wysłaliśmy link aktywacyjny. Otwórz skrzynkę pocztową, znajdz mail od nas i kliknij w link, aby dokończyć rejestrację. Jeśli nie widzisz maila od nas sprawdz folder ze spamem."
        bodyMessage.textColor = MMColors.violetDark
        bodyMessage.numberOfLines = 5
        
        linkNotArriveLabel.text = "Link nie dotarł?"
        linkNotArriveLabel.textColor = MMColors.violetLight
        
        configureMailImage()
        
        configureButtons()
        
    }
    
    func configureMailImage() {
        var config = UIImage.SymbolConfiguration(paletteColors: [MMColors.violetDark])
        config = config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 80.0)))

        mailImageView.image = UIImage(systemName: "envelope.open.fill", withConfiguration: config)
    }
    
    func configureButtons() {
        openMailButton.addTarget(self, action: #selector(openMailApp), for: .touchUpInside)
        resendEmailButton.addTarget(self, action: #selector(resendVerificationMail), for: .touchUpInside)
    }
    
    func layoutUI() {
        mailImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(titleLabel, mailImageView, bodyMessage, openMailButton, linkNotArriveLabel, resendEmailButton)
        
        let horizontalPadding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            mailImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            mailImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mailImageView.heightAnchor.constraint(equalToConstant: 100),
            mailImageView.widthAnchor.constraint(equalToConstant: 100),
            
            bodyMessage.topAnchor.constraint(equalTo: mailImageView.bottomAnchor, constant: 30),
            bodyMessage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            bodyMessage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            bodyMessage.heightAnchor.constraint(equalToConstant: 100),
            
            openMailButton.topAnchor.constraint(equalTo: bodyMessage.bottomAnchor, constant: 30),
            openMailButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            openMailButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            openMailButton.heightAnchor.constraint(equalToConstant: 50),
            
            resendEmailButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            resendEmailButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            resendEmailButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            resendEmailButton.heightAnchor.constraint(equalToConstant: 50),
            
            linkNotArriveLabel.bottomAnchor.constraint(equalTo: resendEmailButton.topAnchor, constant: -10),
            linkNotArriveLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            linkNotArriveLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            linkNotArriveLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    //MARK: - Actions
    
    @objc func openMailApp() {
        print("🟡 Opening Mail App")
        if let url = URL(string: "message://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                presentMMAlert(title: "Nie można otworzyć poczty.", message: "Sprawdź czy masz poprawnie skonfigurowanego klienta pocztowego i spóbuj ponownie, lub sprawdź pocztę ręcznie.", buttonTitle: "Ok")
            }
        }
    }
    
    @objc func resendVerificationMail() {
        print("🟡 Resending verification email")
        guard let user = Auth.auth().currentUser else {
            presentMMAlert(title: "Ups.", message: "Coś poszło nie tak. Sprawdź połączenie z internetem i spróbuj ponownie.", buttonTitle: "OK")
            return
        }
        loginManager.sendVerificationMailTo(email: user.email!)
    }
    
    //MARK: - Biding
    
    func addMagicLinkSubscriber() {
        loginManager.recivedMagicLink
            .subscribe(onNext: { [weak self] link in
                guard let self = self else { return }
                print("🟠 Magic link reviced. Opening CompleteUserDetailsVC")
                let destVC = CompleteUserDetailsViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
                destVC.modalPresentationStyle = .fullScreen
                destVC.navigationController?.isNavigationBarHidden = true
                self.present(destVC, animated: false)
            })
            .disposed(by: disposeBag)
    }
}
