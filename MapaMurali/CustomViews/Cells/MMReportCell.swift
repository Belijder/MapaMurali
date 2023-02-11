//
//  MMReportCell.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 10/02/2023.
//

import UIKit

class MMReportCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "MMReportCell"
    let muralImageView = MMSquareImageView(frame: .zero)
    private let muralIDLabel = MMBodyLabel(textAlignment: .left)
    private let userIDLabel = MMBodyLabel(textAlignment: .left)
    private let reportDateLabel = MMBodyLabel(textAlignment: .left)
    private let reportType = MMBodyLabel(textAlignment: .left)
    private let messageLabel = MMBodyLabel(textAlignment: .center)
    
    
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
        messageLabel.numberOfLines = 4
        messageLabel.lineBreakMode = .byWordWrapping
        
        contentView.backgroundColor = .systemBackground
        contentView.addSubviews(muralImageView, muralIDLabel, userIDLabel, reportDateLabel, reportType, messageLabel)
        
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            userIDLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            userIDLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            userIDLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            userIDLabel.heightAnchor.constraint(equalToConstant: 18),
            
            muralImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            muralImageView.topAnchor.constraint(equalTo: userIDLabel.bottomAnchor, constant: 10),
            muralImageView.heightAnchor.constraint(equalToConstant: 80),
            muralImageView.widthAnchor.constraint(equalToConstant: 80),
            
            muralIDLabel.topAnchor.constraint(equalTo: muralImageView.topAnchor),
            muralIDLabel.leadingAnchor.constraint(equalTo: muralImageView.trailingAnchor, constant: padding),
            muralIDLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            muralIDLabel.heightAnchor.constraint(equalToConstant: 18),

            reportDateLabel.topAnchor.constraint(equalTo: muralIDLabel.bottomAnchor, constant: 10),
            reportDateLabel.leadingAnchor.constraint(equalTo: muralImageView.trailingAnchor, constant: padding),
            reportDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            reportDateLabel.heightAnchor.constraint(equalToConstant: 18),
            
            reportType.topAnchor.constraint(equalTo: reportDateLabel.bottomAnchor, constant: 10),
            reportType.leadingAnchor.constraint(equalTo: muralImageView.trailingAnchor, constant: padding),
            reportType.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            reportType.heightAnchor.constraint(equalToConstant: 18),
            
            messageLabel.topAnchor.constraint(equalTo: muralImageView.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            messageLabel.heightAnchor.constraint(equalToConstant: 72),
        ])
    }
    
    
    func set(from report: Report, thumbnailURL: String) {
        muralImageView.downloadImage(fromURL: thumbnailURL, imageType: .thumbnail, docRef: report.muralID, uiImageViewSize: CGSize(width: 80, height: 80))
        muralIDLabel.text = "Mural ID: \(report.muralID)"
        userIDLabel.text = "Zgłaszający: \(report.userID)"
        reportDateLabel.text = "Data zgłoszenia: \(report.reportDate.convertToDayMonthYearFormat())"
        reportType.text = "Typ zgłoszenia: \(report.reportType)"
        messageLabel.text = "Dodatkowe informacje: \(report.message)"
        
        if report.reportType == "Niestosowne treści" {
            reportType.textColor = .systemRed
        }
    }
}
