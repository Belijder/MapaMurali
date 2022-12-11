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
            completion(result.user.uid)
            self.checkIfUserIsLogged()
        }
    }
    
    
    func singUpWithMailVerification(email: String) {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "mapamurali.page.link")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
            if let error = error {
                print("🔴 Error when try to send verification mail. ERROR: \(error)")
                return
            }
            print("🟢 Succesfully sent a verification email")
            UserDefaults.standard.set(email, forKey: "Email")
        }
    }
    
    func checkIfUserIsLogged() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            userIsLoggedIn.onNext(false)
            print("🔴 User is not logged.")
        } else {
            userIsLoggedIn.onNext(true)
            print("\(FirebaseAuth.Auth.auth().currentUser?.uid ?? "Unknown")")
            currentUserID = Auth.auth().currentUser?.uid
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
