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
    case reports = "reports"
}

class DatabaseManager {
    
    //MARK: - Properties
    private let storageRef = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    var lastDeletedMuralID = BehaviorSubject<String>(value: "")
    var lastEditedMuralID = PublishSubject<Mural>()
    var lastReportedMuralID = PublishSubject<String>()
    var lastFavoriteStatusChangeMuralID = PublishSubject<String>()
    var mapPinButtonTappedOnMural = PublishSubject<Mural>()
    var currentUserPublisher = PublishSubject<User>()
    
    var muralItems = BehaviorSubject<[Mural]>(value: [])
    var murals = [Mural]() {
        didSet { muralItems.onNext(murals) }
    }
    
    var unreviewedMuralsPublisher = BehaviorSubject<[Mural]>(value: [])
    var unreviewedMurals = [Mural]() {
        didSet { unreviewedMuralsPublisher.onNext(unreviewedMurals) }
    }
    
    var reportedMuralsPublisher = BehaviorSubject<[Mural]>(value: [])
    var reportedMurals = [Mural]() {
        didSet { reportedMuralsPublisher.onNext(reportedMurals) }
    }
    
    var reportsPublisher = BehaviorSubject<[Report]>(value: [])
    var reports = [Report]() {
        didSet { reportsPublisher.onNext(reports) }
    }
    
    var observableUsersItem = BehaviorSubject<[User]>(value: [])
    var users = [User]() {
        didSet {
            let sortedUsers = users.sorted { $0.muralsAdded > $1.muralsAdded }
            observableUsersItem.onNext(sortedUsers)
        }
    }
    
    var blockedUsersPublisher = BehaviorSubject<[String]>(value: [])
    
    var currentUser: User? {
        didSet {
            if let user = currentUser {
                currentUserPublisher.onNext(user)
                blockedUsersPublisher.onNext(user.blockedUsers)
                if murals.isEmpty { fetchMuralItemsFromDatabase() }
                if users.isEmpty { fetchMostActivUsers() }
                if user.isAdmin {
                    fetchReports()
                }
            }
        }
    }
    
    weak var delegate: DatabaseManagerDelegate?
    
    
    //MARK: - Create
    func addNewUserToDatabase(id: String, userData: [String : Any], avatarImageData: Data, completion: @escaping (Bool) -> Void) {
        let newUserRef = db.collection("users").document(id)
        newUserRef.setData(userData) { error in
            if error != nil {
                completion(false)
            } else {
                self.addImageToStorage(docRef: newUserRef, imageData: avatarImageData, imageType: .avatar) { _ in
                    completion(true)
                }
            }
        }
    }
    
    
    func updateUserData(id: String, data: [String : Any], avatarImageData: Data, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection(CollectionName.users.rawValue).document(id)
        userRef.updateData(data) { error in
            if error != nil {
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
            if error != nil {
                self.delegate?.failedToAddNewItem(errortitle: "Nie udało się dodać muralu", errorMessage: MMError.failedToAddToDB.rawValue)
            } else {
                newItemRef.updateData(["docRef" : newItemRef.documentID])
                self.addImageToStorage(docRef: newItemRef, imageData: thumbnailData, imageType: .thumbnail) { _ in
                    self.addImageToStorage(docRef: newItemRef, imageData: fullSizeImageData, imageType: .fullSize) { _ in
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
                    guard let url = url else { return }
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
                guard let user = self.currentUser else { return }
                self.murals = []
                
                for document in querySnapshot!.documents {
                    let docRef = self.db.collection(CollectionName.murals.rawValue).document(document.documentID)
                    docRef.getDocument(as: Mural.self) { result in
                        switch result {
                        case .success(let mural):
                            if !user.blockedUsers.contains(where: { $0 == mural.addedBy }) {
                                if mural.reviewStatus == 1 {
                                    self.murals.append(mural)
                                } else if mural.reviewStatus == 0 {
                                    self.unreviewedMurals.append(mural)
                                } else if mural.reviewStatus == 2 {
                                    self.reportedMurals.append(mural)
                                }

                                if mural.reviewStatus == 0 && mural.addedBy == self.currentUser?.id {
                                    self.murals.append(mural)
                                }
                                
                                if mural.reviewStatus == 2 && mural.addedBy == self.currentUser?.id {
                                    self.murals.append(mural)
                                }
                            }
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
                if mural.reviewStatus == 0 {
                    self.unreviewedMurals.append(mural)
                }
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
        guard let currentUser = currentUser else { return }
        
        db.collection(CollectionName.users.rawValue).order(by: "muralsAdded").limit(to: 10).getDocuments { querySnapshot, error in
            if error != nil {
                return
            } else {
                for doc in querySnapshot!.documents {
                    let docRef = self.db.collection(CollectionName.users.rawValue).document(doc.documentID)
                    docRef.getDocument(as: User.self) { result in
                        switch result {
                        case .success(let user):
                            if !currentUser.blockedUsers.contains(where: { $0 == user.id }) && user.muralsAdded > 0 {
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
    
    
    func changeNumberOfMuralsAddedBy(user id: String, by value: Int64) {
        let docRef = db.collection(CollectionName.users.rawValue).document(id)
        docRef.updateData([
            "muralsAdded": FieldValue.increment(value)
        ]) { error in
            if error != nil {
                return
            } else {
                if let index = self.users.firstIndex(where: { $0.id == id }) {
                    self.users[index].muralsAdded += Int(value)
                }
            }
        }
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
    
    
    // MARK: - Admin methods
    func acceptMural(muralID: String) {
        let muralRef = db.collection(CollectionName.murals.rawValue).document(muralID)
        muralRef.updateData([
            "reviewStatus": 1,
        ])
        
        guard let index = unreviewedMurals.firstIndex(where: { $0.docRef == muralID }) else { return }
        var acceptedMural = unreviewedMurals[index]
        unreviewedMurals.remove(at: index)
        
        if murals.contains(where: { $0.docRef == acceptedMural.docRef }) {
            guard let muralIndex = murals.firstIndex(where: { $0.docRef == muralID }) else { return }
            murals[muralIndex].reviewStatus = 1
        } else {
            acceptedMural.reviewStatus = 1
            murals.append(acceptedMural)
        }
    }
    
    
    func addNewReport(muralID: String, userID: String, reportType: ReportType, completion: @escaping (Result<String, MMError>) -> Void) {
        let newReportRef = db.collection(CollectionName.reports.rawValue).document()
        var data = [String : Any]()
        data["muralID"] = muralID
        data["userID"] = userID
        data["reportID"] = newReportRef.documentID
        data["reportType"] = reportType.rawValue
        data["reportDate"] = Date.now
        newReportRef.setData(data) { error in
            guard error == nil else {
                completion(.failure(.failedToAddNewReport))
                return
            }

            completion(.success(newReportRef.documentID))
        }
    }
    
    
    func addAdditionalMessageFor(reportID: String, message: String) {
        let reportRef = db.collection(CollectionName.reports.rawValue).document(reportID)
        reportRef.updateData([
            "message": message
        ])
    }
    

    func changeMuralReviewStatus(muralID: String, newStatus: Int, completion: @escaping (Result<Bool, MMError>) -> Void) {
        let muralRef = db.collection(CollectionName.murals.rawValue).document(muralID)
        muralRef.updateData([
            "reviewStatus": newStatus
        ]) { error in
            guard error == nil else {
                completion(.failure(MMError.failedToChangeMuralReviewStatus))
                return
            }
            
            if let index = self.murals.firstIndex(where: { $0.docRef == muralID }) {
                var mural = self.murals[index]
                mural.reviewStatus = newStatus
                self.murals.remove(at: index)
                if !self.reportedMurals.contains(where: { $0.docRef == muralID}) && newStatus == 2 {
                    self.reportedMurals.append(mural)
                }
            } else if let index = self.reportedMurals.firstIndex(where: { $0.docRef == muralID }) {
                let mural = self.reportedMurals[index]
                self.reportedMurals.remove(at: index)
                if !self.murals.contains(where: { $0.docRef == muralID }) && newStatus == 1 {
                    self.murals.append(mural)
                }
            }
            
            completion(.success(true))
        }
    }
    
    
    func fetchReports() {
        db.collection(CollectionName.reports.rawValue).getDocuments { querySnapshot, error in
            if error != nil {
                return
            } else {
                self.reports = []
                for document in querySnapshot!.documents {
                    let reportRef = self.db.collection(CollectionName.reports.rawValue).document(document.documentID)
                    reportRef.getDocument(as: Report.self) { result in
                        switch result {
                        case .success(let report):
                            self.reports.append(report)
                        case .failure(_):
                            break
                        }
                    }
                }
            }
        }
    }
    
    
    func removeReport(for id: String, completion: @escaping (Bool) -> Void) {
        let reportRef = db.collection(CollectionName.reports.rawValue).document(id)
        
        reportRef.delete(completion: { error in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
    
    func blockUserContent(userID: String, completion: @escaping (Bool) -> Void) {
        guard let user = currentUser else {
            completion(false)
            return
        }
        
        var blockedUsers = user.blockedUsers
        blockedUsers.append(userID)
        
        let userRef = db.collection(CollectionName.users.rawValue).document(user.id)
        
        userRef.updateData([
            "blockedUsers": blockedUsers
        ]) { error in
            if error != nil {
                completion(false)
            } else {
                self.currentUser?.blockedUsers = blockedUsers
                
                var deletedMuralsIDs = [String]()
                for mural in self.murals {
                    if mural.addedBy == userID {
                        deletedMuralsIDs.append(mural.docRef)
                    }
                }

                self.murals.removeAll { $0.addedBy == userID }
                
                for id in deletedMuralsIDs {
                    self.lastDeletedMuralID.onNext(id)
                }
                
                if self.users.contains(where: { $0.id == userID }) {
                    self.users.removeAll(where: { $0.id == userID })
                }
                
                completion(true)
            }
        }
    }
    
    func unblockUserContent(userID: String, completion: @escaping (Bool) -> Void) {
        guard let user = currentUser else {
            completion(false)
            return
        }
        
        let userRef = db.collection(CollectionName.users.rawValue).document(user.id)
        
        var blockedUsers = user.blockedUsers
        blockedUsers.removeAll(where: { $0 == userID })
        
        userRef.updateData([
            "blockedUsers": blockedUsers
        ]) { error in
            if error != nil {
                completion(false)
            } else {
                self.currentUser?.blockedUsers = blockedUsers
                
                self.db.collection(CollectionName.murals.rawValue).whereField("addedBy", isEqualTo: userID).whereField("reviewStatus", isEqualTo: 1)
                    .getDocuments { querySnapshot, error in
                        if error != nil {
                            return
                        } else {
                            for document in querySnapshot!.documents {
                                let docRef = self.db.collection(CollectionName.murals.rawValue).document(document.documentID)
                                docRef.getDocument(as: Mural.self) { result in
                                    switch result {
                                    case .success(let mural):
                                        if !self.murals.contains(where: { $0.docRef == mural.docRef }) {
                                            self.murals.append(mural)
                                        }
                                    case .failure(_):
                                        break
                                    }
                                }
                            }
                        }
                    }
                
                self.users = []
                self.fetchMostActivUsers()
                completion(true)
            }
        }
    }
}
