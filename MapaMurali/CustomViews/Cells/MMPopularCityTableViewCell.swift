//
//  MMPopularCityTableViewCell.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 06/11/2022.
//

import UIKit

class MMPopularCityTableViewCell: UITableViewCell {

    static let identifier = "MMPopularCityTableViewCell"
    
    let cityName = MMTitleLabel(textAlignment: .left, fontSize: 15)
    let muralsCount = MMTitleLabel(textAlignment: .right, fontSize: 20)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(city: PopularCity) {
        cityName.text = city.name
        muralsCount.text = "\(city.muralsCount)"
    }
    
    private func configure() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubviews(cityName, muralsCount)
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            cityName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cityName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            cityName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -100),
            cityName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            muralsCount.centerYAnchor.constraint(equalTo: cityName.centerYAnchor),
            muralsCount.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            muralsCount.leadingAnchor.constraint(equalTo: cityName.trailingAnchor, constant: 20)
        ])
    }
    
}
