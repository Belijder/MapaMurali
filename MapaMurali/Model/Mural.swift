//
//  Mural.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 26/09/2022.
//

import Foundation

struct Mural: Codable {
    let longitude: Double
    let latitude: Double
    let adress: String
    let author: String?
    let addedBy: String
    let imagePath: String?
    let thumbnailPath: String?
}
