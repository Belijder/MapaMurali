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
    
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Set up
    private func configure() {
        addSubview(muralImageView)
        muralImageView.pinToEdges(of: self)
    }
    
    
    final func set(imageURL: String, imageType: ImageType, docRef: String, uiImageViewSize: CGSize) {
        muralImageView.downloadImage(fromURL: imageURL, imageType: imageType, docRef: docRef, uiImageViewSize: uiImageViewSize)
    }
}
