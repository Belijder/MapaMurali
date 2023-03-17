//
//  MMAnnotationView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 02/10/2022.
//

import UIKit
import MapKit

final class MMAnnotationView: MKAnnotationView, AnimatorCellProtocol {
    
    //MARK: - Properties
    static let reuseIdentifier = "MMAnnotationReuseID"
    var muralImageView = MMSquareImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))

    
    //MARK: - Initialization
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Logic
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            muralImageView.layer.borderColor = MMColors.primary.cgColor
        }
    }
    
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(muralImageView)
        NSLayoutConstraint.activate([
            muralImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            muralImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            muralImageView.heightAnchor.constraint(equalToConstant: 40),
            muralImageView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    
    func setImage(thumbnailURL: String, docRef: String) {
        canShowCallout = false
        
        muralImageView.downloadImage(fromURL: thumbnailURL, imageType: .thumbnail, docRef: docRef, uiImageViewSize: CGSize(width: 40, height: 40))
        
        self.layer.cornerRadius = RadiusValue.mapPinRadiusValue
        self.layer.borderWidth = 2
        self.layer.borderColor = MMColors.primary.cgColor
        self.clipsToBounds = true
    }
}
