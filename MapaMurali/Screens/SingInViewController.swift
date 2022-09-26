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
    
    var loginManager = LoginManager()
    var databaseManager = DatabaseManager()
    
    var bag = DisposeBag()
    
    private let nameTextField = MMTextField(placeholder: "e-mail", type: .email)
    private let passwordTextField = MMTextField(placeholder: "hasło", type: .password)
    private let singInButton = MMTintedButton(color: .systemGreen, title: "Zaloguj")
    
    private let registerLabel = MMBodyLabel(textAlignment: .center)
    private let registerButton = MMPlainButton(color: .systemGreen, title: "Zarejestruj się")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(nameTextField, passwordTextField, singInButton, registerLabel, registerButton)
        
        registerLabel.text = "Nie masz konta?"
        singInButton.addTarget(self, action: #selector(tryToSingIn), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(singUpButtonPressed), for: .touchUpInside)
        
        layoutUI()
        addSingInObserver()
        logintestowy()
        
        
    }
    
    //TESTOWA DO LOGOWANIA
    private func logintestowy() {
        let login = "test@t.com"
        let password = "asd123"
        loginManager.singIn(email: login, password: password)
    }
    
    override func viewDidLayoutSubviews() {
        nameTextField.styleTextFieldWithBottomBorder(color: .systemGreen)
        passwordTextField.styleTextFieldWithBottomBorder(color: .systemGreen)
    }
    
    
    @objc func tryToSingIn(sender: UIButton!) {
        // Check email and password to singIn
        guard let login = nameTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        loginManager.singIn(email: login, password: password)
    }
    
    @objc func singUpButtonPressed(sender: UIButton!) {
        let vc = SingUpViewController(loginManager: loginManager)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func addSingInObserver() {
        loginManager.userIsLoggedIn
            .subscribe(onNext: { value in
                if value == true {
                    let vc = MainTabBarViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            })
            .disposed(by: bag)
    }
    
    
    func layoutUI() {
        
        let padding: CGFloat = 20

        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),

            passwordTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: padding),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            singInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            singInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            singInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            singInButton.heightAnchor.constraint(equalToConstant: 50),
            
            registerLabel.topAnchor.constraint(equalTo: singInButton.bottomAnchor, constant: padding),
            registerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            registerLabel.trailingAnchor.constraint(equalTo: view.centerXAnchor),
            registerLabel.heightAnchor.constraint(equalToConstant: 20),
            
            registerButton.centerYAnchor.constraint(equalTo: registerLabel.centerYAnchor),
            registerButton.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            registerButton.heightAnchor.constraint(equalToConstant: 20),
            
        ])
    }
}
