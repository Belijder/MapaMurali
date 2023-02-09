//
//  Report.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 09/02/2023.
//

import Foundation

struct Report: Decodable {
    let muralID: String
    let userID: String
    let reportID: String
    let reportType: String
}
