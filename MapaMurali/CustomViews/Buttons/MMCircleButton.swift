//
//  MMCircleButton.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 17/09/2022.
//

import UIKit

class MMCircleButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(color: UIColor, systemImageName: String) {
        self.init(frame: .zero)
        set(color: color, systemImageName: systemImageName)
        
    }
    
    private func configure() {
        configuration = .filled()
        configuration?.cornerStyle = .capsule
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    final func set(color: UIColor, systemImageName: String) {
        configuration?.image = UIImage(systemName: systemImageName)
        configuration?.baseBackgroundColor = .systemBackground.withAlphaComponent(0.2)
        configuration?.baseForegroundColor = color
        configuration?.imagePadding = 4
    }
}
