//
//  SingUpViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 04/08/2022.
//

import UIKit
import FirebaseAuth
import RxSwift

class SingUpViewController: UIViewController {
    
    //MARK: - Properties
    let loginManager: LoginManager
    let databaseManager: DatabaseManager
    var bag = DisposeBag()
    
    private let emailTextField = MMTextField(placeholder: "email", type: .email)
    private let passwordTextField = MMTextField(placeholder: "hasło", type: .password)
    private let confirmPasswordTextField = MMTextField(placeholder: "powtórz hasło", type: .password)
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
        view.addSubviews(emailTextField, passwordTextField, confirmPasswordTextField, singUpButton)
        configureUIElements()
        layoutUI()
        addMagicLinkSubscriber()
        addSingInObserver()
    }
    
    override func viewDidLayoutSubviews() {
        passwordTextField.styleTextFieldWithBottomBorder(color: MMColors.primary)
        confirmPasswordTextField.styleTextFieldWithBottomBorder(color: MMColors.primary)
        emailTextField.styleTextFieldWithBottomBorder(color: MMColors.primary)
    }
    
    
    
    //MARK: - Set up
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Załóż konto"
        navigationController?.isNavigationBarHidden = false
    }
    
    
    func configureUIElements() {
        singUpButton.addTarget(self, action: #selector(singUpButtonTapped), for: .touchUpInside)
    }
    
    
    func layoutUI() {
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: padding),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            singUpButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: padding),
            singUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            singUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            singUpButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    //MARK: - Actions
    @objc func singUpButtonTapped() {
        guard let email = emailTextField.text else {
            presentMMAlert(title: "Podaj e-mail", message: "Uzupełnij pole z email-em i spróbuj ponownie.", buttonTitle: "Ok")
            return
            
        }
        
        guard let password = passwordTextField.text, let confirmedPassword = confirmPasswordTextField.text else {
            presentMMAlert(title: "Zdefiniuj hasło", message: "Uzupełnij pola z hasłem i spróbuj ponownie.", buttonTitle: "Ok")
            return
        }
        
        
        guard password == confirmedPassword else {
            presentMMAlert(title: "Niezgodne hasła", message: MMError.incompatiblePasswords.rawValue, buttonTitle: "Ok")
            return
        }

        
        loginManager.checkIfEmailIsNOTAlreadyRegistered(email: email) { success, error in
            if let error = error {
                self.presentMMAlert(title: "Ups...", message: error.rawValue, buttonTitle: "Ok")
                return
            }
            
            guard success else {
                self.presentMMAlert(title: "Konto już istnieje", message: "Ten mail jest już zarejestrowany w naszej bazie. Zaloguj się.", buttonTitle: "Ok")
                return
            }
            
            self.loginManager.singUp(email: email, password: password) { uid in
                print("🟠 UID is: \(uid)")
            }
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
    
    func addMagicLinkSubscriber() {
        loginManager.recivedMagicLink
            .subscribe(onNext: { link in
                print("🟠 Magic link reviced. Opening CompleteUserDetailsVC")
                let destVC = CompleteUserDetailsViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
                destVC.modalPresentationStyle = .fullScreen
                destVC.navigationController?.isNavigationBarHidden = true
                self.present(destVC, animated: false)
            })
            .disposed(by: bag)
    }
}
