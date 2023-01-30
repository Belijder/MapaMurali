//
//  UITextField+Ext.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 12/09/2022.
//

import UIKit


extension UITextField {
    func styleTextFieldWithBottomBorder(color: UIColor) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.height - 2, width: self.frame.width, height: 2)
        bottomLine.backgroundColor = color.cgColor
        self.layer.addSublayer(bottomLine)
    }
}
