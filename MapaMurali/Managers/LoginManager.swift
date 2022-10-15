//
//  LoginManager.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 31/07/2022.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

class LoginManager {
    
    var userIsLoggedIn = BehaviorSubject<Bool>(value: false)
    
    func singIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if result != nil {
                self.checkIfUserIsLogged()
            }
        }
    }
    
    func checkIfUserIsLogged() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            userIsLoggedIn.onNext(false)
            print("🔴 User is not logged.")
        } else {
            userIsLoggedIn.onNext(true)
            print("\(FirebaseAuth.Auth.auth().currentUser?.uid ?? "Unknown")")
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
}
