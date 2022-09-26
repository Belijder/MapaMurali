//
//  DatabaseManager.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 26/09/2022.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

protocol DatabaseManagerDelegate: AnyObject {
    func successToAddNewItem()
    func failedToAddNewItem(errortitle: String, errorMessage: String)
}

enum ImageType: String {
    case fullSize = "images/"
    case thumbnail = "thumbnails/"
}

class DatabaseManager {
    let storageRef = Storage.storage().reference()
    let db = Firestore.firestore()
    
    weak var delegate: DatabaseManagerDelegate?
    
    func addNewItemToDatabase(itemData: [String : Any], fullSizeImageData: Data, thumbnailData: Data) {
        let newItemRef = db.collection("murals").document()
        newItemRef.setData(itemData) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                self.addImageToStorage(docRef: newItemRef, imageData: thumbnailData, imageType: .thumbnail)
                self.addImageToStorage(docRef: newItemRef, imageData: fullSizeImageData, imageType: .fullSize)
            }
        }
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
}
