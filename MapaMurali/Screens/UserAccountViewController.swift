//
//  UserAccountViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 30/07/2022.
//

import UIKit

class UserAccountViewController: UIViewController {
    
    var loginManager: LoginManager
    
    private let logOutButton: UIButton = {
        let button = UIButton(configuration: .tinted(), primaryAction: nil)
        button.setTitle("Logout", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        view.addSubview(logOutButton)
        addConstraints()
    }
    
    @objc func logOut(_ sender: UIButton!) {
        loginManager.singOut()
        self.dismiss(animated: true)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            logOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
