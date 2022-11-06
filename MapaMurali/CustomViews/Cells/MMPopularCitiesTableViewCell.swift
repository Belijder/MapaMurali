//
//  MMPopularCitiesTableViewCell.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 06/11/2022.
//

import UIKit

protocol MMPopularCitiesTableViewProtocol: AnyObject {
    func didSelectRowWithCityName(city: String)
}

class MMPopularCitiesTableViewCell: UITableViewCell {

    static let identifier = "MMPopularCitiesTableViewCell"
    
    var cities = [PopularCity]()
    weak var delegate: MMPopularCitiesTableViewProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let citiesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MMPopularCityTableViewCell.self, forCellReuseIdentifier: MMPopularCityTableViewCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    func setupUI() {
        contentView.addSubviews(citiesTableView)
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        citiesTableView.separatorColor = .clear
    }
    
    func set(cities: [PopularCity]) {
        self.cities = cities
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        citiesTableView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            citiesTableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            citiesTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            citiesTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            citiesTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        
        citiesTableView.backgroundColor = .secondarySystemBackground
        citiesTableView.layer.cornerRadius = 20
    }
}

extension MMPopularCitiesTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = citiesTableView.dequeueReusableCell(withIdentifier: MMPopularCityTableViewCell.identifier) as! MMPopularCityTableViewCell
        cell.set(city: cities[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectRowWithCityName(city: cities[indexPath.row].name)
    }
}
