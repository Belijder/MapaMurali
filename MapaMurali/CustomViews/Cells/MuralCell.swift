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
    
    
    final func set(imageURL: String, imageType: ImageType, docRef: String, uiImageViewSize: CGSize, reviewStatus: Int) {
        muralImageView.downloadImage(fromURL: imageURL, imageType: imageType, docRef: docRef, uiImageViewSize: uiImageViewSize)
        if reviewStatus == 0 && muralImageView.subviews.count == 0 {
            addStatusOverlay(frame: CGRect(x: 0, y: 0, width: uiImageViewSize.width, height: uiImageViewSize.height))
        }
    }
    
    
    private func addStatusOverlay(frame: CGRect) {
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.4)
        
        var configuration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 30))
        configuration = configuration.applying(UIImage.SymbolConfiguration(paletteColors: [MMColors.secondary]))
        guard let eyeImage = UIImage(systemName: "eye")?.withConfiguration(configuration) else { return }
        let eyeImageView = UIImageView(frame: CGRect(x: overlayView.bounds.midX - (eyeImage.size.width / 2),
                                                     y: overlayView.bounds.midY - (eyeImage.size.height / 2),
                                                     width: eyeImage.size.width,
                                                     height: eyeImage.size.height))
        
        eyeImageView.image = eyeImage
        overlayView.addSubview(eyeImageView)
        
        self.muralImageView.addSubview(overlayView)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        muralImageView.subviews.forEach { $0.removeFromSuperview() }
    }
}
