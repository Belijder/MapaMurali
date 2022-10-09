//
//  MMAnnotationClusterView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 03/10/2022.
//

import UIKit
import MapKit

final class MMAnnotationClusterView: MKAnnotationView {

    private let countLabel = UILabel()
    
    static let reuseIdentifier = "MMAnnotationCluserView"
    
    override var annotation: MKAnnotation? {
        willSet {
            if let annotation = annotation as? MKClusterAnnotation {
                countLabel.text = "\(annotation.memberAnnotations.count)"
            }
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        displayPriority = .defaultHigh
        collisionMode = .circle
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 50)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = MMColors.primary
        addSubviews(countLabel)
        countLabel.pinToEdges(of: self)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
