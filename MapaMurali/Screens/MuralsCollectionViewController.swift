//
//  MuralsCollectionViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 09/10/2022.
//

import UIKit

class MuralsCollectionViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Mural>!
    var databaseManager: DatabaseManager
    
    var filteredMurals = [Mural]()
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        updateData(on: databaseManager.murals)
        
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MuralCell.self, forCellWithReuseIdentifier: MuralCell.reuseID)
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Mural>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, mural) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MuralCell.reuseID, for: indexPath) as! MuralCell
            cell.set(imageURL: mural.thumbnailURL)
            
            return cell
        })
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Szukaj"
        navigationItem.searchController = searchController
    }
    
    func updateData(on murals: [Mural]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Mural>()
        snapshot.appendSections([.main])
        snapshot.appendItems(murals)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}



extension MuralsCollectionViewController: UICollectionViewDelegate {
    
}


extension MuralsCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredMurals.removeAll()
            updateData(on: databaseManager.murals)
            return
        }
        
        filteredMurals = databaseManager.murals.filter {
            $0.adress.lowercased().contains(filter.lowercased()) ||
            $0.author!.lowercased().contains(filter.lowercased()) ||
            $0.addedBy.lowercased().contains(filter.lowercased())
        }
        updateData(on: filteredMurals)
    }
}
