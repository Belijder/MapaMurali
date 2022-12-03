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
    
    var imageView: MMAnnotationPinImageView?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        imageView = MMAnnotationPinImageView(annotation: annotation)
        frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        canShowCallout = false
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        guard let imageView = imageView else { return }

        addSubview(imageView)
        imageView.frame = bounds
    }
}
