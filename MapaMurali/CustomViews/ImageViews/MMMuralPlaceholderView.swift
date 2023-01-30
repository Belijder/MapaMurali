//
//  MMMuralPlaceholderView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 17/09/2022.
//

import UIKit

class MMMuralPlaceholderView: UIView {
    
    let cameraImage = UIImageView()
    private let label = MMBodyLabel(textAlignment: .center)

    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(cameraImage, label)
        configure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Set up
    private func configure() {
        cameraImage.translatesAutoresizingMaskIntoConstraints = false
        cameraImage.image = UIImage(systemName: "camera.viewfinder")
        var config = UIImage.SymbolConfiguration(paletteColors: [.secondaryLabel])
        config = config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 80.0)))
        cameraImage.preferredSymbolConfiguration = config
        
        label.numberOfLines = 2
        label.text = "Stuknij, aby \ndodać zdjęcie."
        
        NSLayoutConstraint.activate([
            cameraImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cameraImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30),
            
            label.topAnchor.constraint(equalTo: cameraImage.bottomAnchor, constant: 10),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
