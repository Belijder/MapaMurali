//
//  MuralDetailsViewModel.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 23/10/2022.
//

import Foundation
import Firebase
import RxSwift

class MuralDetailsViewModel {
    
    let databaseManager: DatabaseManager
    var currentUserItem: User?
    let muralID: String
    var isUserFavorite = BehaviorSubject(value: false)
    var favoriteImageName = "heart"
    
    init(databaseManager: DatabaseManager, muralID: String) {
        self.databaseManager = databaseManager
        self.muralID = muralID
        fetchUserData()
        
    }
    
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("🔴 Falied to get user uid from database.")
            return
        }
        
        databaseManager.fetchUserFromDatabase(id: uid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUserItem = user
                self.isFavorite(muralID: self.muralID)
            case .failure(let error):
                print("🔴 Falied to get user info from database. Error: \(error).")
            }
        }
    }
    
    func isFavorite(muralID: String) {
        guard let user = currentUserItem else { return }
        if user.favoritesMurals.contains(muralID) {
            isUserFavorite.onNext(true)
        } else {
            isUserFavorite.onNext(false)
        }
    }
    
    
    func favoriteButtonTapped() {
        guard let user = currentUserItem else {
            print("🔴 User Item not exists.")
            return
        }
        
        do {
            if try isUserFavorite.value() == false {
                databaseManager.addToFavorites(userID: user.id, muralID: muralID) { isSuccess in
                    if isSuccess {
                        self.isUserFavorite.onNext(true)
                    } else {
                        // Something went wrong with adding to favorites
                        return
                    }
                }
            } else {
                databaseManager.removeFromFavorites(userID: user.id, muralID: muralID) { isSuccess in
                    if isSuccess {
                        self.isUserFavorite.onNext(false)
                    } else {
                        // Something went wrong with removeing from favorites
                        return
                    }
                }
            }
        } catch {
            print("🔴 Failed to read values of isUserFavorite. Error: \(error)")
        }
    }
    
    
    
    
}
