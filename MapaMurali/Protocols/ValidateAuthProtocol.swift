//
//  ValidateAuthProtocol.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 27/03/2023.
//

import UIKit
import FirebaseAuth

protocol ValidateAuthProtocol: UIViewController {
    var databaseManager: DatabaseManager { get }
    var loginManager: LoginManager { get }
    func validateAuth() -> Void
}

extension ValidateAuthProtocol {
    
    /**
     Call this function to check if the user is currently log in.
     1. Make sure that current user in DatabaseManager is nil. If isn't check if his display name is empty.
        * If is present Complete UserDetails.
        * otherwise, finish Auth Validation - user is log in and verified.
     2. If current user in DatabaseManager is nil, check if current user in FirebaseAuth is also nil.
        * If that's true present SignInVC,
        * otherwise go to step 3 - user is log in to firebase.
     3. Check if his email is verified. If is try to fetch current user data from database.
        * If that is success, validateAuth again,
        * if isn't present CompleteUserDetailsVC.
        * If function catchs error, present SignInVC.
     4. If email isn't verified, try to reload user status. If that is success, check if current user in DatabaseManager is still nil.
        * If is, present CompleteUserDetailsVC.
        * If isn't present VerificationEmailSendVC.
    */
    func validateAuth() {
        guard databaseManager.currentUser == nil else {
            if databaseManager.currentUser!.displayName.isEmpty {
                let destVC = CompleteUserDetailsViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
                destVC.modalPresentationStyle = .fullScreen
                self.present(destVC, animated: false)
            }
            return
        }
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let destVC = SingInViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
            destVC.modalPresentationStyle = .fullScreen
            destVC.navigationController?.navigationBar.tintColor = MMColors.primary
            destVC.navigationController?.navigationBar.backItem?.title = "Zaloguj się"
            present(destVC, animated: false)
        } else {
            if FirebaseAuth.Auth.auth().currentUser?.isEmailVerified == false {
                loginManager.reloadUserStatus { success in
                    if success {
                        if self.databaseManager.currentUser == nil {
                            let destVC = CompleteUserDetailsViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
                            destVC.modalPresentationStyle = .fullScreen
                            self.present(destVC, animated: false)
                        } else {
                            return
                        }
                    } else {
                        let destVC = VerificationEmailSendViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
                        destVC.modalPresentationStyle = .fullScreen
                        self.present(destVC, animated: false)
                    }
                }
            } else {
                if databaseManager.currentUser == nil {
                    do {
                        try databaseManager.fetchCurrenUserData() { success in
                            if success {
                                self.validateAuth()
                            } else {
                                let destVC = CompleteUserDetailsViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
                                destVC.modalPresentationStyle = .fullScreen
                                self.present(destVC, animated: false)
                            }
                        }
                    } catch {
                        let destVC = SingInViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
                        destVC.modalPresentationStyle = .fullScreen
                        self.present(destVC, animated: false)
                    }
                }
            }
        }
    }
}
