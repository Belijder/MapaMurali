//
//  MMMuralImageView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 17/09/2022.
//

import UIKit

class MMMuralImageView: UIImageView {
    
    let placeholderView = MMMuralPlaceholderView()
//    let removeImageButton = MMCircleButton(color: .label, systemImageName: "xmark")

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    private func configureRemoveImageButton() {
//        removeImageButton.alpha = 0.0
//        removeImageButton.addTarget(self, action: #selector(removeImage), for: .touchUpInside)
//    }
    
    private func configure() {
        addSubViews(placeholderView)
        
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 20
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
        layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    func removeImage() {
        image = nil
        layer.borderColor = UIColor.secondaryLabel.cgColor
        placeholderView.alpha = 1.0
    }
    
}
