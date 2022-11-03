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
    let avatarURL: String
    let displayName: String
    let favoritesMurals: [String]
    let muralsAdded: Int
}
