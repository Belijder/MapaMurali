//
//  LoginViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 30/07/2022.
//

import UIKit
import RxSwift
import RxCocoa


class SingInViewController: UIViewController {
    
    //MARK: - Properties
    private var loginManager: LoginManager
    private let databaseManager: DatabaseManager
    private var disposeBag = DisposeBag()
    
    private let logoImage = UIImageView(image: MMImages.violetLogo)
    private let titleLabel = MMTitleLabel(textAlignment: .left, fontSize: 20)
    
    private let emailTextField = MMTextField(placeholder: "e-mail", type: .email)
    private let passwordTextField = MMTextField(placeholder: "hasło", type: .password)
    private let singInButton = MMFilledButton(foregroundColor: .white, backgroundColor: MMColors.violetDark, title: "Zaloguj się")
    
    private let registerButton = MMBodyLabel(textAlignment: .center)
    private let resetPasswordButton = MMBodyLabel(textAlignment: .center)
    
    
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
        view.backgroundColor = MMColors.orangeDark
        
        configureUIElements()
        layoutUI()
        addSingInObserver()
        createDissmisKeyboardTapGesture()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginManager.checkIfUserIsLogged()
    }
    
    
    override func viewDidLayoutSubviews() {
        emailTextField.styleTextFieldWithBottomBorder(color: MMColors.violetDark)
        passwordTextField.styleTextFieldWithBottomBorder(color: MMColors.violetDark)
    }
    
    
    //MARK: - Set up
    private func configureUIElements() {
        logoImage.contentMode = .scaleAspectFit
        
        titleLabel.text = "Logowanie"
        titleLabel.textColor = MMColors.violetDark
        
        emailTextField.delegate = self
        emailTextField.tag = 1
        emailTextField.returnKeyType = .next
        emailTextField.attributedPlaceholder = NSAttributedString(string: "e-mail",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        passwordTextField.delegate = self
        passwordTextField.tag = 2
        passwordTextField.returnKeyType = .done
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "hasło",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        
        singInButton.addTarget(self, action: #selector(tryToSingIn), for: .touchUpInside)
        
        registerButton.textColor = MMColors.violetLight
        registerButton.createStringWithUnderlinedTextForRegistracionForm(plainText: "Nie masz konta?", textToUnderline: "Zarejestruj się")
        let registerTap = UITapGestureRecognizer(target: self, action: #selector(singUpButtonPressed))
        registerButton.isUserInteractionEnabled = true
        registerButton.addGestureRecognizer(registerTap)
        
        resetPasswordButton.createStringWithUnderlinedTextForRegistracionForm(plainText: "Nie pamiętasz hasła?", textToUnderline: "Zresetuj hasło")
        let resetPasswordTap = UITapGestureRecognizer(target: self, action: #selector(resetPasswordButtonTapped))
        resetPasswordButton.isUserInteractionEnabled = true
        resetPasswordButton.addGestureRecognizer(resetPasswordTap)
    }
    
    
    private func layoutUI() {
        view.addSubviews(logoImage, titleLabel, emailTextField, passwordTextField, singInButton, registerButton, resetPasswordButton)
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 20

        [titleLabel, emailTextField, passwordTextField, singInButton, registerButton, resetPasswordButton].forEach { element in
            element.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
            element.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true
        }
        
        [emailTextField, passwordTextField, singInButton].forEach { $0.heightAnchor.constraint(equalToConstant: 50).isActive = true }
        
        NSLayoutConstraint.activate([
            logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.heightAnchor.constraint(equalToConstant: 40),
            logoImage.widthAnchor.constraint(equalToConstant: 216),
            
            titleLabel.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 40),
            titleLabel.heightAnchor.constraint(equalToConstant: 35),
            
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: padding),
            singInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            
            registerButton.topAnchor.constraint(equalTo: singInButton.bottomAnchor, constant: 30),
            registerButton.heightAnchor.constraint(equalToConstant: 20),
            
            resetPasswordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            resetPasswordButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    
    private func createDissmisKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    //MARK: - Logic
    private func validateFields() -> Message? {
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return Message(title: "Uzupełnij pola", body: "Aby się zalogować musisz wypełnić pola z adresem email i hasłem.")
        }
        
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isEmailValid(cleanedEmail) == false {
            return Message(title: "Nieprawidłowy email", body: "Ten email nie wygląda na prawidłowy. Popraw adres i spróbuj ponownie.")
        }
        
        return nil
    }
    
    //MARK: - Actions
    @objc private func tryToSingIn(sender: UIButton!) {
        let faildMessage = validateFields()
        if faildMessage != nil {
            presentMMAlert(title: faildMessage!.title, message: faildMessage!.body, buttonTitle: "Ok")
            return
        }
        
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        loginManager.singIn(email: cleanedEmail, password: cleanedPassword) { message in
            if message != nil {
                self.presentMMAlert(title: message!.title, message: message!.body, buttonTitle: "Ok")
            }
        }
    }
    
    @objc private func singUpButtonPressed(sender: UIButton!) {
        let singUpVC = SingUpViewController(loginManager: loginManager, databaseManager: databaseManager)
        singUpVC.modalPresentationStyle = .fullScreen
        singUpVC.navigationController?.isNavigationBarHidden = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Powrót do logowania", style: .plain, target: nil, action: nil)
        
        self.present(singUpVC, animated: true)
    }
    
    @objc private func resetPasswordButtonTapped() {
        print("🟡 Reset password button Tapped")
        
        let alert = UIAlertController(title: "Zresetuj hasło",
                                      message: "Aby zresetować hasło podaj adres mailowy, którego został użyto podczas zakładania konta.",
                                      preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = "e-mail"
            field.clearButtonMode = .unlessEditing
            field.returnKeyType = .continue
        }
        
        alert.addAction(UIAlertAction(title: "Cofnij", style: .cancel))
        alert.addAction(UIAlertAction(title: "Zresetuj hasło", style: .default) { _ in
            guard let email = alert.textFields![0].text else {
                return
            }

            self.loginManager.resetPasswordFor(email: email) { result in
                switch result {
                case .success(_):
                    self.presentMMAlert(title: "Gotowe", message: "Na podany adres mailowy został wysłany link pozwalający na zmianę hasła. Sprawdź pocztę.", buttonTitle: "Ok")
                case .failure(let error):
                    self.presentMMAlert(title: "Ups coś poszło nie tak.", message: error.rawValue, buttonTitle: "Ok")
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    
    //MARK: - Binding
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
extension SingInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
