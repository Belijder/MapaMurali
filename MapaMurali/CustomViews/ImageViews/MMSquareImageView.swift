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
        if let thumbnailImage = placeholderImage {
            image = thumbnailImage.aspectFittedToHeight(50)
        }
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func downloadImage(fromURL url: String, imageType: ImageType, docRef: String, uiImageViewSize: CGSize) {
        do {
            try ImagesManager.shared.fetchDownsampledImageFromDirectory(from: url, imageType: imageType, name: docRef, uiImageSize: uiImageViewSize, completed: { [weak self] image in
                guard let self = self else { return }
                guard let image = image else {
                    guard let unknownErrorImage = MMImages.placeholderUnknownError else { return }
                    self.image = unknownErrorImage
                    return
                }
                let squareImage = image.cropImageToSquare()
                
                DispatchQueue.main.async {
                    self.image = squareImage
                }
            })
        } catch {
            ImagesManager.shared.downloadImage(from: url, imageType: imageType, name: docRef) { [weak self] image in
                guard let self = self else { return }
                guard let image = image else {
                    guard let noConnectionErrorImage = MMImages.placeholderNoConnection else { return }
                    self.image = noConnectionErrorImage
                    return
                }
                let squareImage = image.cropImageToSquare()
                
                DispatchQueue.main.async {
                    self.image = squareImage
                }
            }
        }
    }
    
    
    func downloadImageAndCropItToCircle(fromURL url: String, imageType: ImageType, docRef: String, uiImageViewSize: CGSize) {
        do {
            try ImagesManager.shared.fetchDownsampledImageFromDirectory(from: url, imageType: imageType, name: docRef, uiImageSize: uiImageViewSize, completed: { [weak self] image in
                guard let self = self else { return }
                guard let image = image else { return }
                self.setUpCircleImage(image: image)
            })
        } catch {
            ImagesManager.shared.downloadImage(from: url, imageType: imageType, name: docRef) { [weak self] image in
                guard let self = self else { return }
                guard let image = image else { return }
                self.setUpCircleImage(image: image)
            }
        }
    }
    
    
    private func setUpCircleImage(image: UIImage) {
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
