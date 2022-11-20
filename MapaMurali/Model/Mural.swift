//
//  Mural.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 26/09/2022.
//

import Foundation

struct Mural: Codable, Hashable {
    let docRef: String
    let longitude: Double
    let latitude: Double
    let adress: String
    let city: String
    let author: String?
    let addedBy: String
    let addedDate: Date
    let imageURL: String
    let thumbnailURL: String
    var favoritesCount: Int
}
