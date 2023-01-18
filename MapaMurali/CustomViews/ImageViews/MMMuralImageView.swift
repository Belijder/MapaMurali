//
//  MMMuralImageView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 17/09/2022.
//

import UIKit

class MMMuralImageView: UIImageView {
    
    let placeholderView = MMMuralPlaceholderView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        addSubviews(placeholderView)
        
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = RadiusValue.muralCellRadiusValue
        clipsToBounds = true
        layer.borderWidth = 2
        layer.borderColor = UIColor.secondaryLabel.cgColor
        
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
    
        ])
    }
    
    func didSelectedImage() {
        placeholderView.alpha = 0.0
        layer.borderColor = MMColors.primary.cgColor
    }
    
    func removeImage() {
        image = nil
        layer.borderColor = UIColor.secondaryLabel.cgColor
        placeholderView.alpha = 1.0
    }
    
}
