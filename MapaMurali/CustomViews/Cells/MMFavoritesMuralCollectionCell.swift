//
//  MMFavoritesMuralCollectionCell.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 01/11/2022.
//

import UIKit

class MMFavoritesMuralCollectionCell: UICollectionViewCell {
    
    static let identifier = "MMFavoritesMuralCollectionCell"
    
    let muralImageView = MMSquareImageView(frame: .zero)
    var favoritesCounter = MMTitleLabel(textAlignment: .center, fontSize: 16)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        muralImageView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            contentView.layer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func set(mural: Mural) {
        muralImageView.downloadImage(fromURL: mural.thumbnailURL, imageType: .thumbnail, docRef: mural.docRef)
        favoritesCounter.createFavoriteCounterTextLabel(counter: mural.favoritesCount, imagePointSize: 16)
    }
    
    private func configure() {
        contentView.layer.cornerRadius = 20
        contentView.layer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
        addSubviews(muralImageView, favoritesCounter)
        
        
        let padding: CGFloat = 0
        
        NSLayoutConstraint.activate([
            muralImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            muralImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            muralImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            muralImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor),
            
            favoritesCounter.topAnchor.constraint(equalTo: muralImageView.bottomAnchor),
            favoritesCounter.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            favoritesCounter.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            favoritesCounter.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
  
}
