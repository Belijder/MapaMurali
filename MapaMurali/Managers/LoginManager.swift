//
//  LoginManager.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 31/07/2022.
//

import Foundation
import Firebase
import FirebaseAuth
import RxSwift
import RxCocoa

class LoginManager {
    
    //MARK: - Properities
    var currentUserID = Auth.auth().currentUser?.uid
    var userIsLoggedIn = BehaviorSubject<Bool>(value: false)
    var recivedMagicLink = PublishSubject<String>()
    
    
    //MARK: - Sign in
    func signIn(email: String, password: String, completion: @escaping (MessageTuple?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                let nsError = error as NSError
                let errorMessage = self.handleFirebaseError(nsError)
                completion(errorMessage)
            } else {
                if result != nil {
                    self.checkIfUserIsLogged()
                }
            }
        }
    }
    
    
    func handleFirebaseError(_ error: NSError) -> MessageTuple {
        switch error.code {
        case 17011:
            return MMMessages.accountNotExist
        case 17010:
            return MMMessages.accountTemporarilyBlocked
        case 17009:
            return MMMessages.wrongPassword
        default:
            return (title: MMMessages.customErrorTitle, message: error.localizedDescription)
        }
    }
    
    
    func resetPasswordFor(email: String, completion: @escaping (Result<Bool, MMError>) -> Void) {
        checkIfEmailIsNOTAlreadyRegistered(email: email) { mailIsNotRegistered, error in
            guard error == nil else {
                completion(.failure(MMError.failedToFetchSignInMethods))
                return
            }
            
            guard mailIsNotRegistered == false else {
                completion(.failure(MMError.accountNotExist))
                return
            }
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if error != nil {
                    completion(.failure(MMError.failedToSendPasswordResset))
                } else {
                    completion(.success(true))
                }
            }
        }
    }
    
    
    //MARK: - Sign up
    func signUp(email: String, password: String, completion: @escaping (String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard let result = result else { return }
            guard let userEmail = result.user.email else {
                return
            }

            self.sendVerificationMailTo(email: userEmail)
            self.currentUserID = result.user.uid
            self.checkIfUserIsLogged()
            
            completion(result.user.uid)
        }
    }
    
    
    func sendVerificationMailTo(email: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: String(format: "https://www.mapamurali.page.link/?email=%@", user.email!))
        actionCodeSettings.handleCodeInApp = false
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        user.sendEmailVerification(with: actionCodeSettings, completion: { error in
            if error != nil {
                return
            }
            UserDefaults.standard.set(email, forKey: Setup.kEmail)
        })
    }
    
    
    func reloadUserStatus(completion: @escaping (Bool) -> Void) {
        Auth.auth().currentUser?.reload(completion: { error in
            if error != nil {
                completion(false)
            } else {
                if Auth.auth().currentUser?.isEmailVerified == true {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        })
    }
    
    
    func checkIfUserIsLogged() {
        guard let user = Auth.auth().currentUser else {
            userIsLoggedIn.onNext(false)
            return
        }
        
        userIsLoggedIn.onNext(true)
        currentUserID = user.uid
    }

    
    func checkIfEmailIsNOTAlreadyRegistered(email: String, completion: @escaping (Bool, MMError?) -> Void) {
        Auth.auth().fetchSignInMethods(forEmail: email) { providers, error in
            if error != nil {
                completion(false, MMError.failedToFetchSignInMethods)
            }
            
            if providers == nil {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    
    //MARK: - Sign out
    func signOut() {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                userIsLoggedIn.onNext(false)
            } catch {
                return
            }
        }
    }
    
    
    func deleteAccount(password: String, completion: @escaping (Result<String, MMError>) -> Void) {
        //Check if user exist.
        guard let user = Auth.auth().currentUser else {
            completion(.failure(MMError.defaultError))
            return
        }

        user.delete { error in
            if error != nil {
                //Try to reauthenticate user
                self.reauthenticateUser(password: password) { result in
                    switch result {
                    case .success(_):
                        user.delete { error in
                            if error != nil {
                                completion(.failure(MMError.unableToDeleteAccount))
                            } else {
                                completion(.success(user.uid))
                            }
                        }
                    case .failure(_):
                        completion(.failure(MMError.reauthenticateError))
                    }
                }
            } else {
                completion(.success(user.uid))
            }
        }
    }
    
    
    func reauthenticateUser(password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: password)

        user?.reauthenticate(with: credential) { _, error in
          if let error = error {
              completion(.failure(error))
          } else {
              completion(.success(true))
          }
        }
    }
}
