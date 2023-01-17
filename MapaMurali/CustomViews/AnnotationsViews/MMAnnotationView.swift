//
//  MMAnnotationView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 02/10/2022.
//

import UIKit
import MapKit

final class MMAnnotationView: MKAnnotationView {
    
    static let reuseIdentifier = "MMAnnotationReuseID"
    
    var muralImageView = MMSquareImageView(frame: .zero)

    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        canShowCallout = false
        
        guard let annotation = annotation,
              let stringURL = annotation.subtitle,
              let docRef = annotation.title else {
            print("🔴 Error geting url and docRef from annotation")
            return
        }

        muralImageView.downloadImageAndCropItToCircle(fromURL: stringURL ?? "", imageType: .thumbnail, docRef: docRef ?? "")

        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
}
