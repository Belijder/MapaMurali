//
//  MMUserAddedMuralTableViewCell.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 14/11/2022.
//

import UIKit

class MMUserAddedMuralTableViewCell: UITableViewCell {
    
    static let identifire = "MMUserAddedMuralTableViewCell"
    let muralImageView = MMSquareImageView(frame: .zero)
    private let adressLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    private let dateLabel = MMBodyLabel(textAlignment: .left)
    
    
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Set up
    private func configure() {
        contentView.backgroundColor = .systemBackground
        contentView.addSubviews(muralImageView, adressLabel, dateLabel)
        
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            muralImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            muralImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            muralImageView.heightAnchor.constraint(equalToConstant: 80),
            muralImageView.widthAnchor.constraint(equalToConstant: 80),
            
            adressLabel.leadingAnchor.constraint(equalTo: muralImageView.trailingAnchor, constant: padding),
            adressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            adressLabel.bottomAnchor.constraint(equalTo: muralImageView.centerYAnchor),
            adressLabel.heightAnchor.constraint(equalToConstant: 20),
            
            dateLabel.leadingAnchor.constraint(equalTo: muralImageView.trailingAnchor, constant: padding),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            dateLabel.topAnchor.constraint(equalTo: muralImageView.centerYAnchor),
            dateLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    
    func set(from mural: Mural) {
        muralImageView.downloadImage(fromURL: mural.thumbnailURL, imageType: .thumbnail, docRef: mural.docRef)
        adressLabel.text = mural.adress
        dateLabel.font = UIFont.systemFont(ofSize: 10)
        dateLabel.text = "Data dodania: \(mural.addedDate.convertToDayMonthYearFormat())"
    }
}
