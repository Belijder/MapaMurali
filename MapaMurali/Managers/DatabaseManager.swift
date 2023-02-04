//
//  DatabaseManager.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 26/09/2022.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift
import RxSwift

protocol DatabaseManagerDelegate: AnyObject {
    func successToAddNewItem(muralID: String)
    func failedToAddNewItem(errortitle: String, errorMessage: String)
    func successToEditMuralData(muralID: String, data: EditedDataForMural)
    func failedToEditMuralData(errorMessage: String)
}

enum ImageType: String {
    case fullSize = "images/"
    case thumbnail = "thumbnails/"
    case avatar = "avatars/"
}

enum CollectionName: String {
    case murals = "murals"
    case users = "users"
    case legalTerms = "legalTerms"
}

class DatabaseManager {
    
    //MARK: - Properties
    private let storageRef = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    var muralItems = BehaviorSubject<[Mural]>(value: [])
    var lastDeletedMuralID = BehaviorSubject<String>(value: "")
    var lastEditedMuralID = PublishSubject<Mural>()
    var lastFavoriteStatusChangeMuralID = PublishSubject<String>()
    var mapPinButtonTappedOnMural = PublishSubject<Mural>()
    var currentUserPublisher = PublishSubject<User>()
    
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
    
    var currentUser: User? {
        didSet {
            if let user = currentUser {
                currentUserPublisher.onNext(user)
                if murals.isEmpty { fetchMuralItemsFromDatabase() }
                if users.isEmpty { fetchMostActivUsers() }
            }
        }
    }
    
    weak var delegate: DatabaseManagerDelegate?
    
    
    //MARK: - Create
    func addNewUserToDatabase(id: String, userData: [String : Any], avatarImageData: Data, completion: @escaping (Bool) -> Void) {
        let newUserRef = db.collection("users").document(id)
        newUserRef.setData(userData) { error in
            if let error = error {
                print("🔴 Error when try to add new user: \(error)")
                completion(false)
            } else {
                self.addImageToStorage(docRef: newUserRef, imageData: avatarImageData, imageType: .avatar) { _ in
                    print("🟢 New user successfuly added to database.")
                    completion(true)
                }
            }
        }
    }
    
    
    func updateUserData(id: String, data: [String : Any], avatarImageData: Data, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection(CollectionName.users.rawValue).document(id)
        userRef.updateData(data) { error in
            if let error = error {
                print("🔴 Error upading user data. ERROR: \(error.localizedDescription)")
                completion(false)
            } else {
                self.removeImageFromStorage(imageType: .avatar, docRef: id) { _ in
                    self.addImageToStorage(docRef: userRef, imageData: avatarImageData, imageType: .avatar) { _ in
                        completion(true)
                    }
                }
            }
        }
    }
    
    
    func addNewItemToDatabase(itemData: [String : Any], fullSizeImageData: Data, thumbnailData: Data) {
        let newItemRef = db.collection(CollectionName.murals.rawValue).document()
        newItemRef.setData(itemData) { error in
            if let error = error {
                print("Error writing document: \(error)")
                self.delegate?.failedToAddNewItem(errortitle: "Nie udało się dodać muralu", errorMessage: MMError.failedToAddToDB.rawValue)
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
    
    
    func addImageToStorage(docRef: DocumentReference, imageData: Data, imageType: ImageType, completion: @escaping (Bool) -> Void) {
        let ref = storageRef.child("\(imageType.rawValue + docRef.documentID).jpg")
        ref.putData(imageData) { result in
                        
            let fieldKey = imageType.rawValue.dropLast(2)
            
            switch result {
            case .success(_):
                ref.downloadURL { url, error in
                    guard let url = url else {
                        //ERROR Przy pobieraniu URL
                        print(error ?? "ERROR Retrieving URL")
                        return
                    }
                    docRef.updateData(["\(fieldKey)URL" : url.absoluteString])
                    completion(true)
                }
            case .failure(_):
                break
            }
        }
    }
    
    
    //MARK: - Read
    func fetchCurrenUserData(completion: @escaping (Bool) -> Void) throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw MMError.failedToFetchCurrentUserData }
        fetchUserFromDatabase(id: userID) { result in
            switch result {
            case .success(let user):
                self.currentUser = user
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
    
    func fetchMuralItemsFromDatabase() {
        db.collection(CollectionName.murals.rawValue).getDocuments { querySnapshot, error in
            if error != nil {
                return
            } else {
                self.murals = []
                for document in querySnapshot!.documents {
                    let docRef = self.db.collection(CollectionName.murals.rawValue).document(document.documentID)
                    docRef.getDocument(as: Mural.self) { result in
                        switch result {
                        case .success(let mural):
                            self.murals.append(mural)
                        case .failure(_):
                            break
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
            case .failure(_):
                break
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
            if error != nil {
                return
            } else {
                for doc in querySnapshot!.documents {
                    let docRef = self.db.collection(CollectionName.users.rawValue).document(doc.documentID)
                    docRef.getDocument(as: User.self) { result in
                        switch result {
                        case .success(let user):
                            if user.muralsAdded > 0 {
                                self.users.append(user)
                            }
                        case .failure(_):
                            break
                        }
                    }
                }
            }
        }
    }
    
    
    func fetchLegalTerms(completion: @escaping (Result<LegalTerms, MMError>) -> Void) {
        let docRef = db.collection(CollectionName.legalTerms.rawValue).document("lZqycsOSTXAUMSQJMZTW")
        docRef.getDocument(as: LegalTerms.self) { result in
            switch result {
            case .success(let terms):
                completion(.success(terms))
            case .failure(_):
                completion(.failure(MMError.failedToGetLegalTerms))
            }
        }
    }
    
    
    //MARK: - Update
    func updateMuralInformations(id: String, data: EditedDataForMural) {
        let muralRef = db.collection(CollectionName.murals.rawValue).document(id)
        muralRef.updateData([
            "address": data.address,
            "city": data.city,
            "latitude": data.location.latitude,
            "longitude": data.location.longitude,
            "author": data.author
        ]) { error in
            if error != nil {
                self.delegate?.failedToEditMuralData(errorMessage: MMError.failedToEditMuralData.rawValue)
            } else {
                self.delegate?.successToEditMuralData(muralID: id, data: data)
            }
        }
    }
    
    
    func changeNumberOfMuralsAddedByUser(by value: Int64) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let docRef = db.collection(CollectionName.users.rawValue).document(userID)
        docRef.updateData([
            "muralsAdded": FieldValue.increment(value)
        ])
    }
    
    
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
                self.lastFavoriteStatusChangeMuralID.onNext(muralID)
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
                self.lastFavoriteStatusChangeMuralID.onNext(muralID)
                completion(true)
            }
        }
    }
    
    
    //MARK: - Delete
    func removeMural(for id: String, completion: @escaping (Bool) -> Void) {
        let muralDocRef = db.collection(CollectionName.murals.rawValue).document(id)
        
        muralDocRef.delete(completion: { error in
            if error != nil {
                return
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
            if error != nil {
                return
            } else {
                completion(true)
            }
        }
    }
    
    
    func removeAllUserData(userID: String, completion: @escaping (Result<Bool, MMError>) -> Void) {
        removeUserProfile(userID: userID) { result in
            switch result {
            case .success(_):
                self.removeImageFromStorage(imageType: .avatar, docRef: userID) { _ in }
                self.removeAllUserAddedMurals(userID: userID) { result in
                    switch result {
                    case .success(_):
                        self.currentUser = nil
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
        var removedMuralCounter = 0 {
            didSet {
                if removedMuralCounter == userAddedMurals.count {
                    completion(.success(true))
                }
            }
        }
        
        let userAddedMurals = murals.filter { $0.addedBy == userID }
        
        guard userAddedMurals.count > 0 else {
            completion(.success(true))
            return
        }
        
        for mural in userAddedMurals {
            removeMural(for: mural.docRef) { success in
                if success {
                    if let index = self.murals.firstIndex(where: { $0.docRef == mural.docRef}) {
                        self.murals.remove(at: index)
                    }
                    removedMuralCounter += 1
                } else {
                    removedMuralCounter += 1
                }
            }
        }
    }
    
    
    func removeUserProfile(userID: String, completion: @escaping (Result<Bool, MMError>) -> Void) {
        let userProfileRef = db.collection(CollectionName.users.rawValue).document(userID)
        
        userProfileRef.delete { error in
            if error != nil {
                completion(.failure(MMError.defaultError))
            } else {
                completion(.success(true))
            }
        }
    }
}
