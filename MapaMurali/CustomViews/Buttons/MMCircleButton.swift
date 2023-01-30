//
//  MMCircleButton.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 17/09/2022.
//

import UIKit

class MMCircleButton: UIButton {

    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(color: UIColor, systemImageName: String) {
        self.init(frame: .zero)
        set(color: color)
        set(systemImageName: systemImageName)
    }
    
    convenience init(color: UIColor) {
        self.init(frame: .zero)
        set(color: color)
    }
    
    
    //MARK: - Set up
    private func configure() {
        configuration = .filled()
        configuration?.cornerStyle = .capsule
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    final func set(color: UIColor) {
        configuration?.baseBackgroundColor = .systemBackground.withAlphaComponent(0.3)
        configuration?.baseForegroundColor = color
        configuration?.imagePadding = 4
    }
    
    
    final func set(systemImageName: String) {
        configuration?.image = UIImage(systemName: systemImageName)
    }
}
