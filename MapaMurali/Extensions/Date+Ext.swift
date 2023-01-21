//
//  Date+Ext.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 09/10/2022.
//

import Foundation

extension Date {
    func convertToDayMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pl_PL")
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
