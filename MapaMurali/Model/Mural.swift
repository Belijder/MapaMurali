//
//  Mural.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 26/09/2022.
//

import Foundation
import CoreLocation

struct Mural: Codable, Hashable {
    let docRef: String
    var longitude: Double
    var latitude: Double
    var adress: String
    var city: String
    var author: String?
    let addedBy: String
    let addedDate: Date
    let imageURL: String
    let thumbnailURL: String
    var favoritesCount: Int
}


struct EditedDataForMural {
    let location: CLLocationCoordinate2D
    let address: String
    let city: String
    let author: String
}
