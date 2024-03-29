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
    var address: String?
    var city: String?
    
    
    func getCoordinate(addressString: String, completion: @escaping (CLLocationCoordinate2D, NSError?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { placemarks, error in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completion(location.coordinate, nil)
                    return
                }
            }
            completion(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    
    func createDataforDatabase(author: String?, location: CLLocationCoordinate2D) throws -> [String : Any] {
        guard let address = address,
              let city = city,
              let user = Auth.auth().currentUser?.uid else {
            throw MMError.failedToAddToDB
        }
        
        var data: [String : Any] = [:]
        data["longitude"] = location.longitude
        data["latitude"] = location.latitude
        data["address"] = address
        data["city"] = city
        data["author"] = author
        data["addedBy"] = user
        data["addedDate"] = Date.now
        data["favoritesCount"] = 0
        data["reviewStatus"] = 0
        return data
    }
}
