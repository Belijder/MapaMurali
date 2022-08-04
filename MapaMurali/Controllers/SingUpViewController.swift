//
//  SingUpViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 04/08/2022.
//

import UIKit

class SingUpViewController: UIViewController {
    
    let loginManager: LoginManager
    
    private let nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "nazwa użytkownika"
        textField.keyboardType = .default
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "e-mail"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "hasło"
        textField.keyboardType = .default
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let singUpButton: UIButton = {
        let button = UIButton(configuration: .tinted(), primaryAction: nil)
        button.setTitle("Zarejestruj się", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let singInLabel: UILabel = {
        let label = UILabel()
        label.text = "Masz już konto?"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    private let singInButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle("Zaloguj się", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(nickNameTextField)
        view.addSubview(nameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(singUpButton)
        
        view.addSubview(singInLabel)
        view.addSubview(singInButton)
        singInButton.addTarget(self, action: #selector(returnToSingInView), for: .touchUpInside)
        addContraints()

    }
    
    override func viewDidLayoutSubviews() {
        Utilities.styleTextField(nameTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleTextField(nickNameTextField)
    }
    
    @objc func returnToSingInView(sender: UIButton!) {
        self.dismiss(animated: true)
    }
    
    
    func addContraints() {
        NSLayoutConstraint.activate([
            nickNameTextField.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: -20),
            nickNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nickNameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            nickNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            nameTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -20),
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.bottomAnchor.constraint(equalTo: singUpButton.topAnchor, constant: -20),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            singUpButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            singUpButton.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            
            singInLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            singInLabel.topAnchor.constraint(equalTo: singUpButton.bottomAnchor, constant: 20),
            
            singInButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            singInButton.topAnchor.constraint(equalTo: singInLabel.bottomAnchor)
        ])
    }
    
    init(loginManager: LoginManager) {
        self.loginManager = loginManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
