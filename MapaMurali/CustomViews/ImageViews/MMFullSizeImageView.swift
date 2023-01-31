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
        ImagesManager.shared.downloadImage(from: url, imageType: imageType, name: docRef) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async { self.image = image }
        }
    }
}
