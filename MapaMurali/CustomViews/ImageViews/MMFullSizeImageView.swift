//
//  MMFullSizeImageView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 08/10/2022.
//

import UIKit

class MMFullSizeImageView: UIImageView {

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
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func downloadImage(from url: String, imageType: ImageType, docRef: String) {
        let size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 3 * 4)
        
        do {
            try ImagesManager.shared.fetchDownsampledImageFromDirectory(from: url, imageType: .fullSize, name: docRef, uiImageSize: size, completed: { [weak self] image in
                guard let self = self else { return }
                self.image = image
            })
        } catch {
            ImagesManager.shared.downloadImage(from: url, imageType: imageType, name: docRef) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async { self.image = image }
            }
        }
    }
}
