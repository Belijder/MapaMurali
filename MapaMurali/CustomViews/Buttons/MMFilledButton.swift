//
//  MMFilledButton.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 13/11/2022.
//

import UIKit

class MMFilledButton: UIButton {

    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(foregroundColor: UIColor, backgroundColor: UIColor, title: String) {
        self.init(frame: .zero)
        set(foregroundColor: foregroundColor, backgroundColor: backgroundColor, title: title)
    }
    
    
    //MARK: - Set up
    private func configure() {
        configuration = .filled()
        configuration?.cornerStyle = .medium
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    final func set(foregroundColor: UIColor, backgroundColor: UIColor, title: String) {
        configuration?.baseForegroundColor = foregroundColor
        configuration?.baseBackgroundColor = backgroundColor
        configuration?.title = title
    }
}
