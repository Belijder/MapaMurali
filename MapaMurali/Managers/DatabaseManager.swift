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
    func successToAddNewItem()
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
        fetchMostActivUsers()
    }
    
    let storageRef = Storage.storage().reference()
    let db = Firestore.firestore()
    
    var muralItems = BehaviorSubject<[Mural]>(value: [])
    var murals = [Mural]()
    
    var users = [User]()
    
    weak var delegate: DatabaseManagerDelegate?
    
    func addNewUserToDatabase(id: String, userData: [String : Any], avatarImageData: Data) {
        let newUserRef = db.collection("users").document(id)
        newUserRef.setData(userData) { error in
            if let error = error {
                print("🔴 Error when try to add new user: \(error)")
            } else {
                self.addImageToStorage(docRef: newUserRef, imageData: avatarImageData, imageType: .avatar)
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
                self.addImageToStorage(docRef: newItemRef, imageData: thumbnailData, imageType: .thumbnail)
                self.addImageToStorage(docRef: newItemRef, imageData: fullSizeImageData, imageType: .fullSize)
                self.increaseNumberOfMuralsAddedByUser()
            }
        }
    }
    
    func increaseNumberOfMuralsAddedByUser() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let docRef = db.collection(CollectionName.users.rawValue).document(userID)
        docRef.updateData([
            "muralsAdded": FieldValue.increment(Int64(1))
        ])
    }
    
    func addImageToStorage(docRef: DocumentReference, imageData: Data, imageType: ImageType) {
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
                    self.delegate?.successToAddNewItem()
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
                            self.muralItems.onNext([mural])
                            print(self.muralItems)
                        case .failure(_):
                            print("FAILED TO GET DOCUMENT: \(document.documentID)")
                        }
                    }
                }
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
                completion(true)
            }
        }
    }
}
