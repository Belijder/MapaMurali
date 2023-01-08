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
    
    func singIn(email: String, password: String, completion: @escaping (Message?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                
                let nsError = error as NSError
                print("🔴 ERROR CODE: \(nsError.code)")
                print("🔴 ERROR DOMAIN: \(nsError.domain)")
                print("🔴 Error.Localized: \(error.localizedDescription)")
                
                let errorMessage = self.handleFirebaseError(nsError)
                completion(errorMessage)
            } else {
                if result != nil {
                    self.checkIfUserIsLogged()
                }
            }
        }
    }
    
    func handleFirebaseError(_ error: NSError) -> Message {
        switch error.code {
        case 17011:
            return Message(title: "Konto nie istnieje.", body: "Ten adres email nie jest przypisany do żadnego konta w naszej bazie. Musisz się zarejestrować.")
        case 17010:
            return Message(title: "Konto tymczasowo zablokowane.", body: "Dostęp do tego konta został tymczasowo zablokowany z powodu wielu nieudanych prób logowania. Możesz je natychmiast przywrócić, resetując hasło lub spróbować ponownie później.")
        case 17009:
            return Message(title: "Nieprawidłowe hasło", body: "Upewnij się, że wpisałeś dobre hasło. Jeśli nie pamiętasz swojego hasła, może je zresetować.")
        default:
            return Message(title: "Ups! Coś poszło nie tak.", body: error.localizedDescription)
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
                print("🔴 Error when try to sent verification mail. ERROR: \(String(describing: error?.localizedDescription))")
                return
            }
            print("🟢 Success to sent verification mail to email: \(String(describing: user.email))")
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
    
    func resetPasswordFor(email: String, completion: @escaping (Result<Bool, MMError>) -> Void) {
        checkIfEmailIsNOTAlreadyRegistered(email: email) { mailIsNotRegistered, error in
            guard error == nil else {
                completion(.failure(MMError.failedToFetchSingInMethods))
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
            print("🔴 User to delete not exist. Escaping failure in func deleteAccount")
            return
        }
        print("🟢 User to delete is exist. Trying to delete user from Database.")

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
                            } else {
                                completion(.success(user.uid))
                                print("🟢 Successfuly deleted user account after reauthenticate.")
                            }
                        }
                    
                    case .failure(let error):
                        print("🔴 Error occured when try to reauthenticate user: \(error)")
                        completion(.failure(MMError.reauthenticateError))
                    }
                }
            } else {
                completion(.success(user.uid))
                print("🟢 Successfuly deleted user account.")
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
