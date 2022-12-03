//
//  DatabaseManager.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 26/09/2022.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import RxSwift
import RxCocoa

protocol DatabaseManagerDelegate: AnyObject {
    func successToAddNewItem(muralID: String)
    func failedToAddNewItem(errortitle: String, errorMessage: String)
}

enum ImageType: String {
    case fullSize = "images/"
    case thumbnail = "thumbnails/"
    case avatar = "avatars/"
}

enum CollectionName: String {
    case murals = "murals"
    case users = "users"
}

class DatabaseManager {
    
    init() {
        fetchMuralItemsFromDatabase()
        fetchMostActivUsers()
        fetchCurrenUserData()
    }
    
    let storageRef = Storage.storage().reference()
    let db = Firestore.firestore()
    
    var muralItems = BehaviorSubject<[Mural]>(value: [])
    var lastDeletedMuralID = BehaviorSubject<String>(value: "")
    
    var murals = [Mural]() {
        didSet {
            muralItems.onNext(murals)
        }
    }
    var users = [User]() {
        didSet {
            let sortedUsers = users.sorted { $0.muralsAdded > $1.muralsAdded }
            observableUsersItem.onNext(sortedUsers)
        }
    }
    
    var observableUsersItem = BehaviorSubject<[User]>(value: [])
    
    var currentUser: User?
    
    weak var delegate: DatabaseManagerDelegate?
    
    func addNewUserToDatabase(id: String, userData: [String : Any], avatarImageData: Data) {
        let newUserRef = db.collection("users").document(id)
        newUserRef.setData(userData) { error in
            if let error = error {
                print("🔴 Error when try to add new user: \(error)")
            } else {
                self.addImageToStorage(docRef: newUserRef, imageData: avatarImageData, imageType: .avatar) { _ in }
            }
        }
    }
    
    func fetchCurrenUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        fetchUserFromDatabase(id: userID) { result in
            switch result {
            case .success(let user):
                self.currentUser = user
                print("🟡 Current User Data Fetched from Database.")
            case .failure(let error):
                print("🔴 Error to fetch curren user data from Database. Error: \(error)")
            }
        }
    }
    
    
    func addNewItemToDatabase(itemData: [String : Any], fullSizeImageData: Data, thumbnailData: Data) {
        let newItemRef = db.collection(CollectionName.murals.rawValue).document()
        newItemRef.setData(itemData) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                newItemRef.updateData(["docRef" : newItemRef.documentID])
                self.addImageToStorage(docRef: newItemRef, imageData: thumbnailData, imageType: .thumbnail) { _ in
                    self.addImageToStorage(docRef: newItemRef, imageData: fullSizeImageData, imageType: .fullSize) { _ in
                        self.changeNumberOfMuralsAddedByUser(by: 1)
                        
                        if let index = self.users.firstIndex(where: { $0.id == self.currentUser?.id }) {
                            self.users[index].muralsAdded += 1
                        }
                        
                        self.delegate?.successToAddNewItem(muralID: newItemRef.documentID)
                    }
                }
            }
        }
    }
    
//    func updateMuralInformations(id: String, itemData: [String : Any], completion: @escaping (Bool) -> ()) {
//        let muralRef = db.collection(CollectionName.murals.rawValue).document(id)
//        muralRef.updateData([
//            "adress": itemData["adress"] 
//        ])
//    }
    
    func changeNumberOfMuralsAddedByUser(by value: Int64) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let docRef = db.collection(CollectionName.users.rawValue).document(userID)
        docRef.updateData([
            "muralsAdded": FieldValue.increment(value)
        ])
    }
    
    
    func addImageToStorage(docRef: DocumentReference, imageData: Data, imageType: ImageType, completion: @escaping (Bool) -> Void) {
        let ref = storageRef.child("\(imageType.rawValue + docRef.documentID).jpg")
        ref.putData(imageData) { result in
                        
            let fieldKey = imageType.rawValue.dropLast(2)
            
            switch result {
            case .success(_):
                ref.downloadURL { url, error in
                    guard let url = url else {
                        //ERROR Przy pobieraniu URL
                        print(error ?? "ERROR Przy pobieraniu URL")
                        return
                    }
                    docRef.updateData(["\(fieldKey)URL" : url.absoluteString])
                    completion(true)
                }
                
            case .failure(_):
                //ERROR PRZY UPLOADZIE ZDJĘCIA DO STORAGE
                break
            }
        }
    }
    
    func fetchMuralItemsFromDatabase() {
        db.collection(CollectionName.murals.rawValue).getDocuments { querySnapshot, error in
            if let error = error {
                print("NIE UDAŁO SIĘ POBRAĆ MURALI Z BAZY DANYCH. ERROR: \(error.localizedDescription)")
            } else {
                for document in querySnapshot!.documents {
                    let docRef = self.db.collection(CollectionName.murals.rawValue).document(document.documentID)
                    docRef.getDocument(as: Mural.self) { result in
                        switch result {
                        case .success(let mural):
                            self.murals.append(mural)
                            print(self.muralItems)
                        case .failure(_):
                            print("FAILED TO GET DOCUMENT: \(document.documentID)")
                        }
                    }
                }
            }
        }
    }
    
    func fetchMuralfromDatabase(with muralID: String) {
        let docRef = db.collection(CollectionName.murals.rawValue).document(muralID)
        
        docRef.getDocument(as: Mural.self) { result in
            switch result {
            case .success(let mural):
                self.murals.append(mural)
            case .failure(let error):
                print("🔴 Error when try to decode mural with id: \(muralID) from Database. ERROR: \(error)")
            }
        }
    }
    
    func fetchUserFromDatabase(id: String, completion: @escaping (Result<User, Error>) -> Void) {
        let docRef = db.collection(CollectionName.users.rawValue).document(id)
        docRef.getDocument(as: User.self) { result in
           completion(result)
        }
    }
    
    func fetchMostActivUsers() {
        db.collection(CollectionName.users.rawValue).order(by: "muralsAdded").limit(to: 10).getDocuments { querySnapshot, error in
            if let error = error {
                print("🔴 Error to fetch most activ users from Database: \(error)")
            } else {
                for doc in querySnapshot!.documents {
                    let docRef = self.db.collection(CollectionName.users.rawValue).document(doc.documentID)
                    docRef.getDocument(as: User.self) { result in
                        switch result {
                        case .success(let user):
                            self.users.append(user)
                        case .failure(let error):
                            print("🔴 Error to fetch user with id \(doc.documentID): \(error)")
                        }
                    }
                }
                print("🟡 Most Activ users Added")
            }
        }
    }
    
    
    
    //MARK: Favorites
    
    func addToFavorites(userID: String, muralID: String, completion: @escaping (Bool) -> Void) {
        let userDocRef = db.collection(CollectionName.users.rawValue).document(userID)
        
        userDocRef.updateData([
            "favoritesMurals": FieldValue.arrayUnion([muralID])
        ]) { [weak self] error in
            
            guard let self = self, error == nil else {
                completion(false)
                return
            }
            
            let muralDocRef = self.db.collection(CollectionName.murals.rawValue).document(muralID)
            muralDocRef.updateData([
                "favoritesCount": FieldValue.increment(Int64(1))
            ]) { error in
                guard error == nil else {
                    completion(false)
                    return
                }
                self.currentUser?.favoritesMurals.append(muralID)
                
                if let muralIndex = self.murals.firstIndex(where: { $0.docRef == muralID }) {
                    self.murals[muralIndex].favoritesCount += 1
                }
                
                completion(true)
            }
        }
    }
    
    func removeFromFavorites(userID: String, muralID: String, completion: @escaping (Bool) -> Void) {
        let userDocRef = db.collection(CollectionName.users.rawValue).document(userID)
        
        userDocRef.updateData([
            "favoritesMurals": FieldValue.arrayRemove([muralID])
        ]) { [weak self] error in
            
            guard let self = self, error == nil else {
                completion(false)
                return
            }
            
            let muralDocRef = self.db.collection(CollectionName.murals.rawValue).document(muralID)
            muralDocRef.updateData([
                "favoritesCount": FieldValue.increment(Int64(-1))
            ]) { error in
                guard error == nil else {
                    completion(false)
                    return
                }
                self.currentUser?.favoritesMurals.removeAll(where: { $0 == muralID })
                
                if let muralIndex = self.murals.firstIndex(where: { $0.docRef == muralID }) {
                    self.murals[muralIndex].favoritesCount -= 1
                }
                
                completion(true)
            }
        }
    }
    
    
    func removeMural(for id: String, completion: @escaping (Bool) -> Void) {
        let muralDocRef = db.collection(CollectionName.murals.rawValue).document(id)
        
        muralDocRef.delete(completion: { error in
            if let error = error {
                print("🔴 Error when try to delete document from database. DocumentID: \(id). ERROR: \(error)")
            } else { 
                self.removeImageFromStorage(imageType: .fullSize, docRef: id) { _ in
                    self.removeImageFromStorage(imageType: .thumbnail, docRef: id) { _ in
                        self.changeNumberOfMuralsAddedByUser(by: -1)
                        
                        if let index = self.users.firstIndex(where: { $0.id == self.currentUser?.id }) {
                            self.users[index].muralsAdded -= 1
                        }
                        
                        completion(true)
                    }
                }
            }
        })
    }
    
    
    func removeImageFromStorage(imageType: ImageType, docRef: String, completion: @escaping (Bool) -> Void) {
        let imageRef = storageRef.child("\(imageType.rawValue + docRef).jpg")
        imageRef.delete { error in
            if let error = error {
                print("🔴 Error when try to delete image from Storage. Image reference: \(imageRef). ERROR: \(error)")
            } else {
                print("🟢 Success to delete image from Storage. Image reference: \(imageRef).")
                completion(true)
            }
        }
    }
    
    func removeAllUserData(userID: String, completion: @escaping (Result<Bool, MMError>) -> Void) {
        removeUserProfile(userID: userID) { result in
            switch result {
            case .success(_):
                self.removeAllUserAddedMurals(userID: userID) { result in
                    switch result {
                    case .success(_):
                        completion(.success(true))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func removeAllUserAddedMurals(userID: String, completion: @escaping (Result<Bool, MMError>) -> Void) {
        var removedMuralCounter = 0
        let userAddedMurals = murals.filter { $0.addedBy == userID }
        for mural in userAddedMurals {
            removeMural(for: mural.docRef) { success in
                if success {
                    print("🟢 Successfuly removed mural from Database.")
                    removedMuralCounter += 1
                    if removedMuralCounter == userAddedMurals.count {
                        completion(.success(true))
                    }
                } else {
                    print("🔴 Error when try to remove mural from Database. DocRef: \(mural.docRef)")
                    removedMuralCounter += 1
                    if removedMuralCounter == userAddedMurals.count {
                        completion(.failure(MMError.defaultError))
                    }
                }
            }
        }
    }
    
    func removeUserProfile(userID: String, completion: @escaping (Result<Bool, MMError>) -> Void) {
        let userProfileRef = db.collection(CollectionName.users.rawValue).document(userID)
        
        userProfileRef.delete { error in
            if let error = error {
                print("🔴 Error when try to delete userAccount. ERROR: \(error)")
                completion(.failure(MMError.defaultError))
            } else {
                print("🟢 Successfuly removed user profile from Database.")
                completion(.success(true))
            }
        }
    }
}
