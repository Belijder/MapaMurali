//
//  MuralCell.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 09/10/2022.
//

import UIKit

class MuralCell: UICollectionViewCell, AnimatorCellProtocol {
    
    static let reuseID = "MuralCell"
    
    var muralImageView = MMSquareImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        addSubview(muralImageView)
        muralImageView.pinToEdges(of: self)
    }
    
    func set(imageURL: String, imageType: ImageType, docRef: String) {
        muralImageView.downloadImage(fromURL: imageURL, imageType: imageType, docRef: docRef)
    }
}
