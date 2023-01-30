//
//  MMAnnotationClusterView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 03/10/2022.
//

import UIKit
import MapKit

final class MMAnnotationClusterView: MKAnnotationView {
    
    //MARK: - Properties
    private let countLabel = UILabel()
    static let reuseIdentifier = "MMAnnotationCluserView"
    
    override var annotation: MKAnnotation? {
        willSet {
            drawAnnotationView(for: self.annotation)
        }
    }
    
    
    //MARK: - Initialization
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        displayPriority = .defaultHigh
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Logic
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            drawAnnotationView(for: self.annotation)
        }
    }
    
    
    func drawAnnotationView(for annotation: MKAnnotation?) {
        if let annotation = annotation as? MKClusterAnnotation {
            
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
            let count = annotation.memberAnnotations.count
            
            image = renderer.image(actions: { _ in
                MMColors.primary.setFill()
                UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40)).fill()
                
                let attributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium)]
                
                let text = "\(count)"
                let size = text.size(withAttributes: attributes)
                let rect = CGRect(x: 20 - size.width / 2, y: 20 - size.height / 2, width: size.width, height: size.height)
                text.draw(in: rect, withAttributes: attributes)
            })
        }
    }
}
