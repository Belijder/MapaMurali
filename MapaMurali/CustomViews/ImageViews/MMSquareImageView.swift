//
//  MMSquareImageView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 09/10/2022.
//

import UIKit

class MMSquareImageView: UIImageView {
    
    let placeholderImage = MMImages.placeholderImage

    //MARK: - Initializaton
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Set up
    private func configure() {
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func downloadImage(fromURL url: String, imageType: ImageType, docRef: String) {
        NetworkManager.shared.downloadImage(from: url, imageType: imageType, name: docRef) { [weak self] image in
            guard let self = self else { return }
            
            guard let image = image else { return }
            let squareImage = image.cropImageToSquare()
            
            DispatchQueue.main.async {
                self.image = squareImage
            }
        }
    }
    
    
    func downloadImageAndCropItToCircle(fromURL url: String, imageType: ImageType, docRef: String) {
        NetworkManager.shared.downloadImage(from: url, imageType: imageType, name: docRef) { [weak self] image in
            guard let self = self else { return }
            guard let image = image else { return }
            
            let thumbnailImage = image.aspectFittedToHeight(50)
            let circleImage = thumbnailImage.cropImageToCircle()
            
            DispatchQueue.main.async {
                self.image = circleImage
                self.layer.masksToBounds = true
                self.layer.borderWidth = 2
                self.layer.borderColor = MMColors.primary.cgColor
                self.layer.cornerRadius = RadiusValue.mapPinRadiusValue
            }
        }
    }
}
