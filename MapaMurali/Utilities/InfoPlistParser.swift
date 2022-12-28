//
//  InfoPlistParser.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 13/12/2022.
//

import Foundation

struct InfoPlistParser {
    static func getStringValue(forKey: String) -> String {
        guard let value = Bundle.main.infoDictionary?[forKey] as? String else {
            fatalError("🔴🔴 No value found for key '\(forKey)' in the Info.plist file")
        }
        return value
    }
}
