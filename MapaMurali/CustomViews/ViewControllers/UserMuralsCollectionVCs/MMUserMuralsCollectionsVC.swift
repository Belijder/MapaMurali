//
//  UserMuralsCollectionsVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 12/11/2022.
//

import UIKit

class MMUserMuralsCollectionsVC: UIViewController {
    
    let collectionView: UICollectionView = {
        let padding: CGFloat = 20
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MuralCell.self, forCellWithReuseIdentifier: MuralCell.reuseID)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        collectionView.layer.cornerRadius = 20
        return collectionView
    }()
    
    let collectionTitle = MMTitleLabel(textAlignment: .left, fontSize: 15)
    let actionButton = MMPlainButton()
    
    var murals: [Mural]!
    
    init(collectionTitle: String, murals: [Mural]) {
        super.init(nibName: nil, bundle: nil)
        self.collectionTitle.text = collectionTitle
        self.murals = murals
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUIElements()
        configureActionButton()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func configureActionButton() {
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    @objc func actionButtonTapped() {}
    
    func layoutUIElements() {
        view.addSubviews(collectionTitle, actionButton, collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionTitle.topAnchor.constraint(equalTo: view.topAnchor),
            collectionTitle.widthAnchor.constraint(equalToConstant: 250),
            collectionTitle.heightAnchor.constraint(equalToConstant: 20),
            
            actionButton.centerYAnchor.constraint(equalTo: collectionTitle.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 150),
            actionButton.heightAnchor.constraint(equalToConstant: 20),
            
            collectionView.topAnchor.constraint(equalTo: collectionTitle.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 140)
            
        ])
    }
}

extension MMUserMuralsCollectionsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return murals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MuralCell.reuseID, for: indexPath) as! MuralCell
        cell.set(imageURL: murals[indexPath.row].imageURL)
        cell.muralImageView.layer.cornerRadius = 20
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("🟡 Item tapped at: \(indexPath.row)")
    }
    
    
}
