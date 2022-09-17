//
//  MMMuralImageView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 17/09/2022.
//

import UIKit

class MMMuralImageView: UIImageView {
    
    let placeholderView = MMMuralPlaceholderView()
    let removeImageButton = MMCircleButton(color: .label, systemImageName: "xmark")

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureRemoveImageButton() {
        removeImageButton.alpha = 0.0
        removeImageButton.addTarget(self, action: #selector(removeImage), for: .touchUpInside)
    }
    
    private func configure() {
        addSubViews(placeholderView, removeImageButton)
        configureRemoveImageButton()
        
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 20
        clipsToBounds = true
        layer.borderWidth = 2
        layer.borderColor = UIColor.secondaryLabel.cgColor
        
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            removeImageButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            removeImageButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            removeImageButton.heightAnchor.constraint(equalToConstant: 44),
            removeImageButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func didSelectedImage() {
        placeholderView.alpha = 0.0
        layer.borderColor = UIColor.systemGreen.cgColor
        removeImageButton.alpha = 1.0
    }
    
    @objc func removeImage() {
        image = nil
        layer.borderColor = UIColor.secondaryLabel.cgColor
        removeImageButton.alpha = 0.0
        placeholderView.alpha = 1.0
    }
    
}
