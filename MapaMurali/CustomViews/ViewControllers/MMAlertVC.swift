//
//  MMAlertVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 23/09/2022.
//

import UIKit

class MMAlertVC: UIViewController {
    
    //MARK: - Properties
    private let containerView = MMAlertContainerView()
    private let titleLabel = MMTitleLabel(textAlignment: .center, fontSize: 20)
    private let messageLabel = MMBodyLabel(textAlignment: .center)
    private let actionButton = MMTintedButton(color: MMColors.primary, title: "Ok")
    
    private var alertTitle: String
    private var alertMessage: String
    private var buttonTitle: String
    private var actionForDismiss: (() -> Void)?
    
    //MARK: - Initialization
    init(title: String, message: String, buttonTitle: String, actionForDismiss: (() -> Void)? = nil) {
        self.alertTitle = title
        self.alertMessage = message
        self.buttonTitle = buttonTitle
        self.actionForDismiss = actionForDismiss
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.addSubviews(containerView, titleLabel, actionButton, messageLabel)
        configure()
        layoutUI()

    }
    
    
    //MARK: - Set up
    private func configure() {
        titleLabel.text = alertTitle
        
        messageLabel.text = alertMessage
        messageLabel.numberOfLines = 5
        
        actionButton.setTitle(buttonTitle, for: .normal)
        actionButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
    }
    
    
    private func layoutUI() {
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 240),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            messageLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -12) 
        ])
    }
    
    
    //MARK: - Actions
    @objc func dismissVC() {
        guard let dismissAction = actionForDismiss else {
            self.dismiss(animated: true)
            return
        }
        
        dismissAction()
    }
}
