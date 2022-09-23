//
//  UIView+Ext.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 12/09/2022.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        for view in views { addSubview(view) }
    }
}
