//
//  MMAvatarImageView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 22/10/2022.
//

import UIKit

class MMAvatarImageView: UIImageView {
    
    private var placeholderImage: UIImage!

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
        let configuration = UIImage.SymbolConfiguration(weight: .thin)
        placeholderImage = UIImage(systemName: "person.crop.circle", withConfiguration: configuration)
        
        image = placeholderImage
        tintColor = .secondaryLabel
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func setImage(from url: String, userID: String) {
        NetworkManager.shared.downloadImage(from: url, imageType: .avatar, name: userID) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.layer.cornerRadius = self.bounds.width / 2.0
                self.image = image
            }
        }
    }
}
