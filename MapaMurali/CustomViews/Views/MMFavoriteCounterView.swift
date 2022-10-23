//
//  FavoriteCounterView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 23/10/2022.
//

import UIKit

class MMFavoriteCounterView: UIView {
    
    let heartImageView = UIImageView(frame: .zero)
    let counterLabel = MMTitleLabel(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(imageHeight: CGFloat, counter: Int, fontSize: CGFloat) {
        self.init(frame: .zero)
        configure(imageHeight: imageHeight, counter: counter, fontSize: fontSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(imageHeight: CGFloat, counter: Int, fontSize: CGFloat) {
        heartImageView.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        heartImageView.addSubview(counterLabel)
        addSubviews(heartImageView)
        
        counterLabel.textAlignment = .right
        counterLabel.font = UIFont.systemFont(ofSize: fontSize)
        counterLabel.text = "\(counter)"
        counterLabel.textColor = .white
        
        heartImageView.image = UIImage(systemName: "heart.fill")
        heartImageView.contentMode = .scaleAspectFit
        heartImageView.tintColor = .systemRed
        heartImageView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            
            heartImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            heartImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            heartImageView.heightAnchor.constraint(equalToConstant: imageHeight),
            heartImageView.widthAnchor.constraint(equalToConstant: imageHeight),
            
            counterLabel.centerXAnchor.constraint(equalTo: heartImageView.centerXAnchor),
            counterLabel.centerYAnchor.constraint(equalTo: heartImageView.centerYAnchor)
            
        
//            heartImageView.topAnchor.constraint(equalTo: self.topAnchor),
//            heartImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant:  -padding),
//            heartImageView.heightAnchor.constraint(equalToConstant: imageHeight),
//            heartImageView.widthAnchor.constraint(equalToConstant: imageHeight),
//
//            counterLabel.leadingAnchor.constraint(equalTo: heartImageView.trailingAnchor, constant: padding),
//            counterLabel.centerYAnchor.constraint(equalTo: heartImageView.centerYAnchor),
//            counterLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            counterLabel.heightAnchor.constraint(equalToConstant: imageHeight)
            
        ]) 
    }
    
}
