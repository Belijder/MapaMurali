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
    
    var currentUserID = Auth.auth().currentUser?.uid
    var userIsLoggedIn = BehaviorSubject<Bool>(value: false)
    
    var recivedMagicLink = PublishSubject<String>()
    
    func singIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if result != nil {
                self.checkIfUserIsLogged()
            }
        }
    }
    
    func singUp(email: String, password: String, completion: @escaping (String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard let result = result else { return }
            guard let userEmail = result.user.email else {
                print("🔴 Cannot find user email for verification.")
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
            print("🔴 Error when try to sent verification mail. User not found.")
            return
        }
        
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: String(format: "https://www.mapamurali.page.link/?email=%@", user.email!))
        actionCodeSettings.handleCodeInApp = false
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        user.sendEmailVerification(with: actionCodeSettings, completion: { error in
            if error != nil {
                print("🔴 Error when try to sent verification mail. ERROR: \(error?.localizedDescription)")
                return
            }
            print("🟢 Success to sent verification mail to email: \( user.email)")
            UserDefaults.standard.set(email, forKey: Setup.kEmail)
        })
    }
    
    
    func checkIfUserIsLogged() {
        guard let user = Auth.auth().currentUser else {
            userIsLoggedIn.onNext(false)
            print("🔴 User is not logged.")
            return
        }
        
        print("🟠 Is user verified: \(user.isEmailVerified) ")
        userIsLoggedIn.onNext(true)
        currentUserID = Auth.auth().currentUser?.uid
        
        if user.isEmailVerified {
            print("\(FirebaseAuth.Auth.auth().currentUser?.uid ?? "Unknown")")
        }
        
    }
    
    func checkIfEmailIsNOTAlreadyRegistered(email: String, completion: @escaping (Bool, MMError?) -> Void) {
        Auth.auth().fetchSignInMethods(forEmail: email) { providers, error in
            if let error = error {
                print("🔴 Error when try to fetch sing In providers for email: \(email). ERROR: \(error.localizedDescription)")
                completion(false, MMError.failedToFetchSingInMethods)
            }
            
            if providers == nil {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    
    func singOut() {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                userIsLoggedIn.onNext(false)
            } catch {
                print("Error when try to SingOut user")
            }
        }
    }
    
    func deleteAccount(password: String, completion: @escaping (Result<String, MMError>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(MMError.defaultError))
            return
        }

        user.delete { error in
            if let error = error {
                print("🟠 Error occured: \(error). Trying to reauthenticate user")
                self.reauthenticateUser(password: password) { result in
                    switch result {
                    case .success(_):
                        user.delete { error in
                            if let error = error {
                                print("🔴 Error occured when try delete accoutn after reauthenticate user: \(error)")
                                completion(.failure(MMError.unableToDeleteAccount))
                                print("🟢 Successfuly deleted user account.")
                            } else {
                                completion(.success(user.uid))
                            }
                        }
                    
                    case .failure(let error):
                        print("🔴 Error occured when try to reauthenticate user: \(error)")
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
