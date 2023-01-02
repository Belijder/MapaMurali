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
    
    private let titleLabel = MMTitleLabel(textAlignment: .left, fontSize: 20)
    
    private let emailTextField = MMTextField(placeholder: "email", type: .email)
    private let passwordTextField = MMTextField(placeholder: "hasło", type: .password)
    private let confirmPasswordTextField = MMTextField(placeholder: "powtórz hasło", type: .password)
    private let singUpButton = MMFilledButton(foregroundColor: .white, backgroundColor: MMColors.violetDark, title: "Zarejestruj się!")
    
    private let acceptTermOfUseLabel = MMBodyLabel(textAlignment: .left)
    private let acceptTermOfUseToggle = UISwitch()
    private let acceptPrivacyPolicyLabel = MMBodyLabel(textAlignment: .left)
    private let acceptPrivacyPolicyToggle = UISwitch()
    private let returnToLogInButton = MMBodyLabel(textAlignment: .center)

    
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
        configureViewController()
        configureUIElements()
        layoutUI()
        addSingInObserver()
        createDissmisKeyboardTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        emailTextField.styleTextFieldWithBottomBorder(color: MMColors.violetDark)
        passwordTextField.styleTextFieldWithBottomBorder(color: MMColors.violetDark)
        confirmPasswordTextField.styleTextFieldWithBottomBorder(color: MMColors.violetDark)
        
    }
    
    
    //MARK: - Set up
    func configureViewController() {
        view.backgroundColor = MMColors.orangeDark
        navigationController?.isNavigationBarHidden = true
    }
    
    
    func configureUIElements() {
        titleLabel.text = "Załóż konto"
        titleLabel.textColor = MMColors.violetDark
        
        emailTextField.textColor = .white
        emailTextField.attributedPlaceholder = NSAttributedString(string: "e-mail",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        
        passwordTextField.textColor = .white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "hasło",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        
        confirmPasswordTextField.textColor = .white
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "powtórz hasło",
                                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        
        setUpLegalTermsSwitches()
        
        singUpButton.addTarget(self, action: #selector(singUpButtonTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(returnToSingInView))
        returnToLogInButton.isUserInteractionEnabled = true
        returnToLogInButton.addGestureRecognizer(tap)
        
        returnToLogInButton.createStringWithUnderlinedTextForRegistracionForm(plainText: "Masz już konto?", textToUnderline: "Zaloguj się")
    }
    
    func setUpLegalTermsSwitches() {
        acceptTermOfUseLabel.createStringWithUnderlinedTextForRegistracionForm(plainText: "Akceptuję", textToUnderline: "Regulamin")
        acceptTermOfUseLabel.textColor = MMColors.violetLight
        
        let termOfUseTap = UITapGestureRecognizer(target: self, action: #selector(termOfUseLabelTapped))
        acceptTermOfUseLabel.isUserInteractionEnabled = true
        acceptTermOfUseLabel.addGestureRecognizer(termOfUseTap)
        
        acceptTermOfUseToggle.onTintColor = MMColors.violetLight
        
        acceptPrivacyPolicyLabel.createStringWithUnderlinedTextForRegistracionForm(plainText: "Akceptuję", textToUnderline: "Politykę Prywatności")
        acceptPrivacyPolicyLabel.textColor = MMColors.violetLight
        
        let privacyPolicyTap = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyLabelTapped))
        acceptPrivacyPolicyLabel.isUserInteractionEnabled = true
        acceptPrivacyPolicyLabel.addGestureRecognizer(privacyPolicyTap)
        
        acceptPrivacyPolicyToggle.onTintColor = MMColors.violetLight
    }
    
    
    func layoutUI() {
        view.addSubviews(titleLabel, emailTextField, passwordTextField, confirmPasswordTextField, acceptTermOfUseLabel, acceptTermOfUseToggle, acceptPrivacyPolicyLabel, acceptPrivacyPolicyToggle, singUpButton, returnToLogInButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        acceptPrivacyPolicyToggle.translatesAutoresizingMaskIntoConstraints = false
        acceptTermOfUseToggle.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
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
            
            acceptTermOfUseLabel.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
            acceptTermOfUseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            acceptTermOfUseLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            acceptTermOfUseLabel.heightAnchor.constraint(equalToConstant: 30),
            
            acceptTermOfUseToggle.centerYAnchor.constraint(equalTo: acceptTermOfUseLabel.centerYAnchor),
            acceptTermOfUseToggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            acceptTermOfUseToggle.heightAnchor.constraint(equalToConstant: 30),
            
            acceptPrivacyPolicyLabel.topAnchor.constraint(equalTo: acceptTermOfUseToggle.bottomAnchor, constant: padding),
            acceptPrivacyPolicyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            acceptPrivacyPolicyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            acceptPrivacyPolicyLabel.heightAnchor.constraint(equalToConstant: 30),
            
            acceptPrivacyPolicyToggle.centerYAnchor.constraint(equalTo: acceptPrivacyPolicyLabel.centerYAnchor),
            acceptPrivacyPolicyToggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            acceptPrivacyPolicyToggle.heightAnchor.constraint(equalToConstant: 30),
            
            singUpButton.topAnchor.constraint(equalTo: acceptPrivacyPolicyToggle.bottomAnchor, constant: padding),
            singUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            singUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            singUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            returnToLogInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            returnToLogInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            returnToLogInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            returnToLogInButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    
    //MARK: - Logic
    func createDissmisKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
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
                let destVC = VerificationEmailSendViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
                destVC.modalPresentationStyle = .fullScreen
                self.present(destVC, animated: true)
            }
        }
    }
    
    @objc func termOfUseLabelTapped() {
        databaseManager.fetchLegalTerms { result in
            switch result {
            case.success(let terms):
                guard let url = URL(string: terms.termOfUse) else {
//                    print("🔴 URL error when try to fetch legal terms.")
                    self.presentMMAlert(title: "Ups! Coś poszło nie tak. ", message: MMError.failedToGetLegalTerms.rawValue, buttonTitle: "Ok")
                    return
                }
                self.presentSafariVC(with: url)
            case .failure(let error):
                self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    @objc func privacyPolicyLabelTapped() {
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
    
    
    @objc func returnToSingInView() {
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
