//
//  Date+Ext.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 09/10/2022.
//

import Foundation

extension Date {
    func convertToDayMonthYearFormat() -> String {
        return formatted(.dateTime.day().month().year())
    }
}
