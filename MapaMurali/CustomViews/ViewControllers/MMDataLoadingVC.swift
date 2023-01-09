//
//  MMDataLoadingVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 18/09/2022.
//

import UIKit

class MMDataLoadingVC: UIViewController {
    
    var containerView: UIView!
    
    func showLoadingView(message: String?) {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.25) { self.containerView.alpha = 0.8 }
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        containerView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        if message != nil {
            let messageLabel = MMBodyLabel(textAlignment: .center)
            containerView.addSubviews(messageLabel)
            messageLabel.text = message
            messageLabel.textColor = .secondaryLabel
            
            NSLayoutConstraint.activate([
                messageLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 30),
                messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
                messageLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingView() {
        self.containerView.removeFromSuperview()
        self.containerView = nil
    }
    
    
    func showEmptyStateView(with message: String, in view: UIView) {
        let emptyStateView = MMEmptyStateView(message: message)
        emptyStateView.frame = view.frame
        view.addSubview(emptyStateView)
    }
    
    func hideEmptyStateView(form view: UIView) {
        let subviews = view.subviews
        
        for subview in subviews {
            if subview is MMEmptyStateView {
                print("🟡 The view contains a subview of type MMEmptyStateView")
                subview.removeFromSuperview()
                print("🟡 The subview of type UIView was removed from superView")
            }
        }
    }
    
    

}
