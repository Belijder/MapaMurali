//
//  MMSquareImageView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 09/10/2022.
//

import UIKit

class MMSquareImageView: UIImageView {
    
    let placeholderImage = UIImage(systemName: "photo")

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func downloadImage(fromURL url: String) {
        NetworkManager.shared.downloadImage(from: url) { [weak self] image in
            guard let self = self else { return }
            
            guard let image = image else { return }
            let squareImage = image.cropImageToSquare()
            
            DispatchQueue.main.async {
                self.image = squareImage
            }
        }
    }

}
