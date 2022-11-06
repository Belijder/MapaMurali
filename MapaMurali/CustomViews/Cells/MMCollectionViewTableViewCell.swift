//
//  MMCollectionViewTableViewCell.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 24/10/2022.
//

import UIKit

protocol MMCollectionViewTableViewProtocol: AnyObject {
    func didSelectItemInCollectionView(muralItem: Mural)
}

class MMCollectionViewTableViewCell: UITableViewCell {
    
    var murals = [Mural]()
    weak var delegate: MMCollectionViewTableViewProtocol?
    
    static let identifier = "MMCollectionViewTableViewCell"
    
    private let collectionView: UICollectionView = {
        let padding: CGFloat = 12
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 140, height: 200)
        layout.sectionInset = UIEdgeInsets(top: 20, left: padding, bottom: 0, right: padding)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MMFavoritesMuralCollectionCell.self, forCellWithReuseIdentifier: MMFavoritesMuralCollectionCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        
        
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.layer.cornerRadius = 20
        
    }
    
    private func setupUI() {
        contentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func set(murals: [Mural]) {
        self.murals = murals
    }
}

extension MMCollectionViewTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return murals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MMFavoritesMuralCollectionCell.identifier, for: indexPath) as! MMFavoritesMuralCollectionCell
        let mural = murals[indexPath.row]
        cell.set(mural: mural)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.didSelectItemInCollectionView(muralItem: murals[indexPath.row])
        
    }
}
