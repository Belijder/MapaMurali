//
//  UserMuralsCollectionsVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 12/11/2022.
//

import UIKit
import simd


class MMUserMuralsCollectionsVC: UIViewController {
    
    enum Section {
        case main
    }
    
    //MARK: - Properties
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
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Mural>!
    
    let collectionTitle = MMTitleLabel(textAlignment: .left, fontSize: 15)
    let actionButton = MMPlainButton()
    let emptyStateLabel = MMBodyLabel(textAlignment: .center)
    
    var murals: [Mural]!
    
    var databaseManager: DatabaseManager!
    
    
    //MARK: - Initialization
    init(collectionTitle: String, murals: [Mural], databaseManager: DatabaseManager) {
        super.init(nibName: nil, bundle: nil)
        self.collectionTitle.text = collectionTitle
        self.murals = murals
        self.databaseManager = databaseManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUIElements()
        configureActionButton()
        collectionView.delegate = self
        configureDataSoure()
    }
    
    //MARK: - Set up
    func configureActionButton() {
        actionButton.configuration?.titleAlignment = .trailing
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    
    func configureDataSoure() {
        dataSource = UICollectionViewDiffableDataSource<Section, Mural>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, mural) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MuralCell.reuseID, for: indexPath) as! MuralCell
            cell.set(imageURL: mural.thumbnailURL)
            cell.muralImageView.layer.cornerRadius = 20
            return cell
        })
    }
    

    func layoutUIElements() {
        view.addSubviews(collectionTitle, actionButton, collectionView)
        collectionView.addSubview(emptyStateLabel)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionTitle.topAnchor.constraint(equalTo: view.topAnchor),
            collectionTitle.widthAnchor.constraint(equalToConstant: 250),
            collectionTitle.heightAnchor.constraint(equalToConstant: 20),
            
            actionButton.centerYAnchor.constraint(equalTo: collectionTitle.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionButton.leadingAnchor.constraint(equalTo: collectionTitle.trailingAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 20),
            
            collectionView.topAnchor.constraint(equalTo: collectionTitle.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 140),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            emptyStateLabel.heightAnchor.constraint(equalToConstant: 30),
            emptyStateLabel.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    //MARK: - Actions
    @objc func actionButtonTapped() {}
    
    
    //MARK: - Logic
    func updateData(on murals: [Mural]) {
        if murals.isEmpty { emptyStateLabel.alpha = 1 } else { emptyStateLabel.alpha = 0 }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Mural>()
        snapshot.appendSections([.main])
        snapshot.appendItems(murals)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

//MARK: - Extensions
extension MMUserMuralsCollectionsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return murals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
    
}
