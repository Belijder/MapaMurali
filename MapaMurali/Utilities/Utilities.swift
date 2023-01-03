//
//  Utilities.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 03/01/2023.
//

import Foundation


enum Utilities {
    
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$")
        return passwordTest.evaluate(with: password)
    }
    
    static func isEmailValid(_ email: String) -> Bool {
        let emailTest = NSPredicate(format: "SELF MATCHES %@", "^[\\p{L}0-9!#$%&'*+\\/=?^_`{|}~-][\\p{L}0-9.!#$%&'*+\\/=?^_`{|}~-]{0,63}@[\\p{L}0-9-]+(?:\\.[\\p{L}0-9-]{2,7})*$")
        return emailTest.evaluate(with: email)
    }
}
