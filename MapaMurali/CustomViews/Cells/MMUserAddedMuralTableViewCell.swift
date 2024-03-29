//
//  MMUserAddedMuralTableViewCell.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 14/11/2022.
//

import UIKit

class MMUserAddedMuralTableViewCell: UITableViewCell {
    
    static let identifier = "MMUserAddedMuralTableViewCell"
    let muralImageView = MMSquareImageView(frame: .zero)
    private let addressLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    private let dateLabel = MMBodyLabel(textAlignment: .left)
    private let statusLabel = MMTitleLabel(textAlignment: .right, fontSize: 10)
    
    
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
        contentView.addSubviews(muralImageView, addressLabel, dateLabel, statusLabel)
        
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            muralImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            muralImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            muralImageView.heightAnchor.constraint(equalToConstant: 80),
            muralImageView.widthAnchor.constraint(equalToConstant: 80),
            
            addressLabel.leadingAnchor.constraint(equalTo: muralImageView.trailingAnchor, constant: padding),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            addressLabel.bottomAnchor.constraint(equalTo: muralImageView.centerYAnchor),
            addressLabel.heightAnchor.constraint(equalToConstant: 20),
            
            dateLabel.leadingAnchor.constraint(equalTo: muralImageView.trailingAnchor, constant: padding),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            dateLabel.topAnchor.constraint(equalTo: muralImageView.centerYAnchor),
            dateLabel.heightAnchor.constraint(equalToConstant: 15),
            
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            statusLabel.heightAnchor.constraint(equalToConstant: 15),
            statusLabel.leadingAnchor.constraint(equalTo: muralImageView.trailingAnchor, constant: padding)
        ])
    }
    
    
    func set(from mural: Mural) {
        muralImageView.downloadImage(fromURL: mural.thumbnailURL, imageType: .thumbnail, docRef: mural.docRef, uiImageViewSize: CGSize(width: 80, height: 80))
        addressLabel.text = mural.address
        dateLabel.font = UIFont.systemFont(ofSize: 10)
        dateLabel.text = "Data dodania: \(mural.addedDate.convertToDayMonthYearFormat())"
        
        switch mural.reviewStatus {
        case 0:
            let text = "Czeka na akceptację"
            statusLabel.createAttributedString(text: text, imageSystemName: "eye", imagePointSize: 10, color: .systemYellow)
        case 1:
            let text = "Zaakceptowano"
            statusLabel.createAttributedString(text: text, imageSystemName: "checkmark", imagePointSize: 10, color: .systemGreen)
        default:
            break
        }
    }
}
