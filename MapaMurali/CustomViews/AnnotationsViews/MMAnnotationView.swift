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
    var muralImageView = MMSquareImageView(frame: .zero)

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
        muralImageView.frame = bounds
    }
    
    func setImage(thumbnailURL: String, docRef: String) {
        frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        canShowCallout = false

        muralImageView.downloadImageAndCropItToCircle(fromURL: thumbnailURL, imageType: .thumbnail, docRef: docRef)
    }
}
