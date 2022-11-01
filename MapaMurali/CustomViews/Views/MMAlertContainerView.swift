//
//  MMAlertContainerView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 23/09/2022.
//

import UIKit

class MMAlertContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = MMColors.primary.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        
    }
}
