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
    var bag = DisposeBag()
    
    
    private let nameTextField = MMTextField(placeholder: "e-mail", type: .email)
    private let passwordTextField = MMTextField(placeholder: "hasło", type: .password)
    
    private let singInButton: UIButton = {
        let button = UIButton(configuration: .tinted(), primaryAction: nil)
        button.setTitle("Zaloguj", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let registerLabel: UILabel = {
        let label = UILabel()
        label.text = "Nie masz konta?"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle("Zarejestruj się", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(nameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(singInButton)
        singInButton.addTarget(self, action: #selector(tryToSingIn), for: .touchUpInside)
        view.addSubview(registerLabel)
        view.addSubview(registerButton)
        registerButton.addTarget(self, action: #selector(singUpButtonPressed), for: .touchUpInside)
        addContraints()
        addSingInObserver()
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: nameTextField.frame.height - 2, width: nameTextField.frame.width, height: 2)
        bottomLine.borderColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        nameTextField.layer.addSublayer(bottomLine)
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
                    let vc = MainTabViewController(loginManager: self.loginManager)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            })
            .disposed(by: bag)
    }

    func addContraints() {
        NSLayoutConstraint.activate([
            nameTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -20),
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.bottomAnchor.constraint(equalTo: singInButton.topAnchor, constant: -20),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            singInButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            singInButton.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            
            registerLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            registerLabel.topAnchor.constraint(equalTo: singInButton.bottomAnchor, constant: 20),
            
            registerButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            registerButton.topAnchor.constraint(equalTo: registerLabel.bottomAnchor)
        ])
    }
}
