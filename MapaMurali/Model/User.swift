//
//  User.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 15/10/2022.
//

import Foundation

struct User: Codable {
    let id: String
    let email: String
    let isAdmin: Bool
    let avatarURL: String
    var displayName: String
    var favoritesMurals: [String]
    var muralsAdded: Int
}
