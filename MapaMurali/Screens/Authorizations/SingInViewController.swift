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
    var loginManager: LoginManager
    let databaseManager: DatabaseManager
    var disposeBag = DisposeBag()
    
    private let logoImage = UIImageView(image: MMImages.violetLogo)
    private let titleLabel = MMTitleLabel(textAlignment: .left, fontSize: 20)
    
    private let emailTextField = MMTextField(placeholder: "e-mail", type: .email)
    private let passwordTextField = MMTextField(placeholder: "hasło", type: .password)
    private let singInButton = MMFilledButton(foregroundColor: .white, backgroundColor: MMColors.violetDark, title: "Zaloguj się")
    
    private let registerButton = MMBodyLabel(textAlignment: .center)
    private let resetPasswordButton = MMBodyLabel(textAlignment: .center)
    
    
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
        view.backgroundColor = MMColors.orangeDark
        
        configureUIElements()
        layoutUI()
        addSingInObserver()
        createDissmisKeyboardTapGesture()
        
        emailTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loginManager.checkIfUserIsLogged()
    }
    
    override func viewDidLayoutSubviews() {
        emailTextField.styleTextFieldWithBottomBorder(color: MMColors.violetDark)
        passwordTextField.styleTextFieldWithBottomBorder(color: MMColors.violetDark)
    }
    
    
    //MARK: - Set up
    
    func configureUIElements() {
        
        logoImage.contentMode = .scaleAspectFit
        
        titleLabel.text = "Logowanie"
        titleLabel.textColor = MMColors.violetDark
        
        emailTextField.delegate = self
        emailTextField.tag = 1
        emailTextField.textColor = .white
        emailTextField.returnKeyType = .next
        emailTextField.attributedPlaceholder = NSAttributedString(string: "e-mail",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        passwordTextField.delegate = self
        passwordTextField.tag = 2
        passwordTextField.textColor = .white
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
    
    func layoutUI() {
        view.addSubviews(logoImage, titleLabel, emailTextField, passwordTextField, singInButton, registerButton, resetPasswordButton)
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 20

        NSLayoutConstraint.activate([
            
            logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.heightAnchor.constraint(equalToConstant: 40),
            logoImage.widthAnchor.constraint(equalToConstant: 216),
            
            titleLabel.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 35),
            
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: padding),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            singInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            singInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            singInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            singInButton.heightAnchor.constraint(equalToConstant: 50),
            
            registerButton.topAnchor.constraint(equalTo: singInButton.bottomAnchor, constant: 30),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            registerButton.heightAnchor.constraint(equalToConstant: 20),
            
            resetPasswordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            resetPasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            resetPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            resetPasswordButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func createDissmisKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    //MARK: - Logic
    
    func validateFields() -> Message? {
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
    @objc func tryToSingIn(sender: UIButton!) {
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
    
    @objc func singUpButtonPressed(sender: UIButton!) {
        let singUpVC = SingUpViewController(loginManager: loginManager, databaseManager: databaseManager)
        singUpVC.modalPresentationStyle = .fullScreen
        singUpVC.navigationController?.isNavigationBarHidden = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Powrót do logowania", style: .plain, target: nil, action: nil)
        
        self.present(singUpVC, animated: true)
    }
    
    @objc func resetPasswordButtonTapped() {
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
            
            // Zresetuj hasło
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
    func addSingInObserver() {
        loginManager.userIsLoggedIn
            .subscribe(onNext: { value in
                if value == true {
                    self.view.window?.rootViewController?.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}

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
