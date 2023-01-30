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
    
    private let databaseManager: DatabaseManager
    private var currentUserItem: User?
    private let muralID: String
    private(set) var isUserFavorite = BehaviorSubject(value: false)
    var favoriteImageName = "heart"
    private(set) var counterValue: Int
    let presentingVCTitle: String?
    
    
    init(databaseManager: DatabaseManager, muralID: String, counterValue: Int, presentingVCTitle: String?) {
        self.databaseManager = databaseManager
        self.muralID = muralID
        self.counterValue = counterValue
        self.presentingVCTitle = presentingVCTitle
        fetchUserData()
    }
    
    
    private func fetchUserData() {
        guard let currentUser = databaseManager.currentUser else {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            databaseManager.fetchUserFromDatabase(id: uid) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let user):
                    self.currentUserItem = user
                    self.isFavorite(muralID: self.muralID)
                case .failure(_):
                   break
                }
            }
            return
        }
        
        currentUserItem = currentUser
        isFavorite(muralID: muralID)
    }
    
    
    private func isFavorite(muralID: String) {
        guard let user = currentUserItem else { return }
        if user.favoritesMurals.contains(muralID) {
            isUserFavorite.onNext(true)
        } else {
            isUserFavorite.onNext(false)
        }
    }
    
    
    func favoriteButtonTapped() {
        guard let user = currentUserItem else { return }
        
        do {
            if try isUserFavorite.value() == false {
                databaseManager.addToFavorites(userID: user.id, muralID: muralID) { isSuccess in
                    if isSuccess {
                        self.counterValue += 1
                        self.isUserFavorite.onNext(true)
                        
                    } else {
                        return
                    }
                }
            } else {
                databaseManager.removeFromFavorites(userID: user.id, muralID: muralID) { isSuccess in
                    if isSuccess {
                        self.counterValue -= 1
                        self.isUserFavorite.onNext(false)
                    } else {
                        return
                    }
                }
            }
        } catch {
            return
        }
    }
}
