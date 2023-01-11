//
//  MuralsCollectionViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 09/10/2022.
//

import UIKit
import RxSwift

class MuralsCollectionViewController: MMDataLoadingVC {
    
    enum Section {
        case main
    }
    
    //MARK: - Properties
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Mural>!
    var databaseManager: DatabaseManager
    var disposeBag = DisposeBag()

    var murals: [Mural] = []
    var filteredMurals: [Mural] = []
    
    
    var isSearching = false
    
    //MARK: - Initialization
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        addMuralsObserver()
        
        if murals.isEmpty && self.title == "Przeglądaj" { murals = databaseManager.murals }
        
        if self.title != "Przeglądaj" {
            navigationController?.navigationBar.prefersLargeTitles = false
            let closeButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(dismissVC))
            navigationItem.leftBarButtonItem = closeButton
            
            if murals.isEmpty {
                showEmptyStateView(with: "Nie masz jeszcze żadnych ulubionych murali.", in: view)
            }
        }
        updateData(on: murals)
        
    }
    
    //MARK: - Set up
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
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Szukaj"
        searchController.searchBar.returnKeyType = .done
        navigationItem.searchController = searchController
    }
    
    //MARK: - Logic
    func updateData(on murals: [Mural]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Mural>()
        snapshot.appendSections([.main])
        snapshot.appendItems(murals)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    //MARK: - Actions
    @objc func dismissVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Binding
    func addMuralsObserver() {
        if title == "Przeglądaj" {
            databaseManager.muralItems
                .subscribe(onNext: { murals in
                    self.murals = murals
                    self.updateData(on: self.murals)
                })
                .disposed(by: disposeBag)
        }
    }
}

//MARK: - Extensions
extension MuralsCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let muralItem = isSearching ? filteredMurals[indexPath.item] : murals[indexPath.item]
        let destVC = MuralDetailsViewController(muralItem: muralItem, databaseManager: databaseManager)
        destVC.title = muralItem.adress
        let navControler = UINavigationController(rootViewController: destVC)
        navControler.modalPresentationStyle = .fullScreen
        self.present(navControler, animated: true)
    }
}

extension MuralsCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredMurals.removeAll()
            updateData(on: murals)
            isSearching = false
            return
        }
        
        isSearching = true
        filteredMurals = databaseManager.murals.filter {
            $0.adress.lowercased().contains(filter.lowercased()) ||
            $0.author!.lowercased().contains(filter.lowercased()) ||
            $0.addedBy.lowercased().contains(filter.lowercased())
        }
        
        updateData(on: filteredMurals)
        
        if filteredMurals.isEmpty {
            showEmptyStateView(with: "Nie znaleziono żadnych murali spełniających kryteria wyszukiwania :(", in: view)
        } else {
            hideEmptyStateView(form: view)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if murals.isEmpty {
            showEmptyStateView(with: "Nie znaleziono żadnych murali spełniających kryteria wyszukiwania :(", in: view)
        } else {
            hideEmptyStateView(form: view)
        }
    }
}
