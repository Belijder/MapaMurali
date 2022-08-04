//
//  Styles.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 04/08/2022.
//

import Foundation
import UIKit

class Utilities {
    static func styleTextField(_ textField: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        textField.borderStyle = .none
        textField.layer.addSublayer(bottomLine)
    }
}
