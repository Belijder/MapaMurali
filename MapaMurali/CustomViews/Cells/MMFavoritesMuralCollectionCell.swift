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
    var favoritesCounter = MMFavoriteCounterView(imageHeight: 40, counter: 0, fontSize: 15)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func set(mural: Mural) {
        muralImageView.downloadImage(fromURL: mural.thumbnailURL)
        favoritesCounter.counterLabel.text = "\(mural.favoritesCount)"
    }
    
    private func configure() {
        addSubviews(muralImageView, favoritesCounter)
        
        muralImageView.layer.cornerRadius = 20
        
        let padding: CGFloat = 0
        
        NSLayoutConstraint.activate([
            muralImageView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            muralImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            muralImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            muralImageView.heightAnchor.constraint(equalTo: muralImageView.widthAnchor),
            
            favoritesCounter.topAnchor.constraint(equalTo: muralImageView.bottomAnchor, constant: 12),
            favoritesCounter.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            favoritesCounter.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            favoritesCounter.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
  
}
