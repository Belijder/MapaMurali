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
    private let loginManager: LoginManager
    private let databaseManager: DatabaseManager
    private var disposeBag = DisposeBag()
    
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
        createDissmisKeyboardTapGesture()
    }
    
    
    override func viewDidLayoutSubviews() {
        emailTextField.styleTextFieldWithBottomBorder(color: MMColors.violetDark)
        passwordTextField.styleTextFieldWithBottomBorder(color: MMColors.violetDark)
        confirmPasswordTextField.styleTextFieldWithBottomBorder(color: MMColors.violetDark)
    }
    
    
    //MARK: - Set up
    private func configureViewController() {
        view.backgroundColor = MMColors.orangeDark
        navigationController?.isNavigationBarHidden = true
    }
    
    
    private func configureUIElements() {
        titleLabel.text = "Załóż konto"
        titleLabel.textColor = MMColors.violetDark
        
        [emailTextField, passwordTextField, confirmPasswordTextField].forEach { $0.delegate = self }
        
        emailTextField.tag = 1
        emailTextField.returnKeyType = .next
        emailTextField.attributedPlaceholder = NSAttributedString(string: "e-mail",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        
        passwordTextField.tag = 2
        passwordTextField.returnKeyType = .next
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "hasło",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        
        confirmPasswordTextField.tag = 3
        confirmPasswordTextField.returnKeyType = .done
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "powtórz hasło",
                                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        
        setUpLegalTermsSwitches()
        
        singUpButton.addTarget(self, action: #selector(singUpButtonTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(returnToSingInView))
        returnToLogInButton.isUserInteractionEnabled = true
        returnToLogInButton.addGestureRecognizer(tap)
        
        returnToLogInButton.createStringWithUnderlinedTextForRegistracionForm(plainText: "Masz już konto?", textToUnderline: "Zaloguj się")
    }
    
    
    private func setUpLegalTermsSwitches() {
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
    
    
    private func layoutUI() {
        view.addSubviews(titleLabel, emailTextField, passwordTextField, confirmPasswordTextField, acceptTermOfUseLabel, acceptTermOfUseToggle, acceptPrivacyPolicyLabel, acceptPrivacyPolicyToggle, singUpButton, returnToLogInButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        acceptPrivacyPolicyToggle.translatesAutoresizingMaskIntoConstraints = false
        acceptTermOfUseToggle.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 20
        
        [titleLabel, emailTextField, passwordTextField, confirmPasswordTextField, acceptTermOfUseLabel, acceptPrivacyPolicyLabel, singUpButton, returnToLogInButton].forEach { element in
            NSLayoutConstraint.activate([
                element.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
                element.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
            ])
        }
        
        [emailTextField, passwordTextField, confirmPasswordTextField, singUpButton].forEach {
                $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        [titleLabel, acceptTermOfUseLabel, acceptTermOfUseToggle, acceptPrivacyPolicyLabel, acceptPrivacyPolicyToggle].forEach {
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: padding),
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            
            acceptTermOfUseLabel.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
            acceptTermOfUseToggle.centerYAnchor.constraint(equalTo: acceptTermOfUseLabel.centerYAnchor),
            acceptTermOfUseToggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            acceptPrivacyPolicyLabel.topAnchor.constraint(equalTo: acceptTermOfUseToggle.bottomAnchor, constant: padding),
            acceptPrivacyPolicyToggle.centerYAnchor.constraint(equalTo: acceptPrivacyPolicyLabel.centerYAnchor),
            acceptPrivacyPolicyToggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            singUpButton.topAnchor.constraint(equalTo: acceptPrivacyPolicyToggle.bottomAnchor, constant: padding),
            returnToLogInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            returnToLogInButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    
    //MARK: - Logic
    private func createDissmisKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    
    private func validateFields() -> Message? {
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return Message(title: "Uzupełnij wymagane pola", body: "Aby założy konto musisz uzupełnić wszystkie wymagane pola")
        }
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmedPassword = confirmPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard password == confirmedPassword else {
            return Message(title: "Niezgodne hasła", body: MMError.incompatiblePasswords.rawValue)
        }
        
        if Utilities.isEmailValid(email) == false {
            return Message(title: "Nieprawidłowy email", body: "Ten email nie wygląda na prawidłowy. Popraw adres i spróbuj ponownie.")
        }
        
        if Utilities.isPasswordValid(password) == false {
            return Message(title: "Hasło zbyt słabe", body: "Upewnij się, że hasło ma minimum 8 znaków oraz zawiera co najmniej jeden znak specjalny i cyfrę.")
        }
        
        if !acceptTermOfUseToggle.isOn || !acceptPrivacyPolicyToggle.isOn {
            return Message(title: "Zaznacz zgody", body: "Aby aktywować konto musisz potwierdzić, że zapoznałeś się i akceptujesz warunki użytkowania oraz politykę prywatności naszej aplikacji.")
        }
        
        return nil
    }
    
    
    //MARK: - Actions
    @objc private func singUpButtonTapped() {
        let errorMessage = validateFields()
        if errorMessage != nil {
            presentMMAlert(title: errorMessage!.title, message: errorMessage!.body, buttonTitle: "Ok")
            return
        }
        
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        loginManager.checkIfEmailIsNOTAlreadyRegistered(email: cleanedEmail) { success, error in
            if let error = error {
                self.presentMMAlert(title: "Ups...", message: error.rawValue, buttonTitle: "Ok")
                return
            }
            
            guard success else {
                self.presentMMAlert(title: "Konto już istnieje", message: "Ten mail jest już zarejestrowany w naszej bazie. Spróbuj się zalogować.", buttonTitle: "Ok")
                return
            }
            
            self.loginManager.singUp(email: cleanedEmail, password: cleanedPassword) { uid in
                let destVC = VerificationEmailSendViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
                destVC.modalPresentationStyle = .fullScreen
                self.present(destVC, animated: true)
            }
        }
    }
    
    
    @objc private func termOfUseLabelTapped() {
        databaseManager.fetchLegalTerms { result in
            switch result {
            case.success(let terms):
                guard let url = URL(string: terms.termOfUse) else {
                    self.presentMMAlert(title: "Ups! Coś poszło nie tak. ", message: MMError.failedToGetLegalTerms.rawValue, buttonTitle: "Ok")
                    return
                }
                self.presentSafariVC(with: url)
            case .failure(let error):
                self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    
    @objc private func privacyPolicyLabelTapped() {
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
    
    
    @objc private func returnToSingInView() {
        self.dismiss(animated: true)
    }
    
    
    //MARK: - Binding
    private func addSingInObserver() {
        loginManager.userIsLoggedIn
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                if value == true {
                    self.navigationController?.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}


//MARK: - Extensions
extension SingUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
