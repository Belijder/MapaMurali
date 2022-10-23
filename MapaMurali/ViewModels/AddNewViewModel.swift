//
//  AddNewViewModel.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 29/09/2022.
//

import Foundation
import MapKit
import Firebase

class AddNewViewModel {
    
    var fullSizeImageData: Data?
    var thumbnailImageData: Data?
    var currentLocation: CLLocation?
    var adress: String?
    
    func createDataforDatabase(author: String?) throws -> [String : Any] {
        
        guard let longitude = currentLocation?.coordinate.longitude,
              let latitude = currentLocation?.coordinate.latitude,
              let adress = adress,
              let user = Auth.auth().currentUser?.uid else {
            print("Error when try to create data for Database")
            throw MMError.failedToAddToDB
        }
    
        var data: [String : Any] = [:]
        data["longitude"] = longitude
        data["latitude"] = latitude
        data["adress"] = adress
        data["author"] = author
        data["addedBy"] = user
        data["addedDate"] = Date.now
        data["favoritesCount"] = 0
        return data
        
    }
}
