//
//  UIViewController+Ext.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 23/09/2022.
//

import Foundation
import UIKit
import SafariServices

extension UIViewController {
    func presentMMAlert(title: String, message: String, buttonTitle: String) {
        let alertVC = MMAlertVC(title: title, message: message, buttonTitle: buttonTitle)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true)
    }
    
    func presentSafariVC(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = MMColors.primary
        present(safariVC, animated: true)
    }
}
