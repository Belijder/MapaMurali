//
//  MuralsCollectionViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 09/10/2022.
//

import UIKit
import RxSwift

class MuralsCollectionViewController: MMAnimableViewController {
    
    enum Section {
        case main
    }
    
    //MARK: - Properties
    private var collectionView: UICollectionView!
    private let noConncectionImageView = UIImageView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Mural>!
    let searchController = UISearchController()
    var deviceIsConnetedToInternet = false
    
    private let databaseManager: DatabaseManager
    private var disposeBag = DisposeBag()

    var murals: [Mural] = []
    private var filteredMurals: [Mural] = []
    
    private var isSearching = false
    
    
    //MARK: - Initialization
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        addMuralsObserver()
        bindConnectionStatus()
        configureNoConnectionImage()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if deviceIsConnetedToInternet == false {
            if !NetworkMonitor.shared.isConnected {
                noConncectionImageView.isHidden = false
                if iTShoudShowNoConnentivityAlert() {
                    presentMMAlert(message: MMMessages.noInternetConnection)
                    NetworkMonitor.shared.lastTimeWhenNoConnentivityAlertWasShown = Date.now
                }
            } else {
                deviceIsConnetedToInternet = true
                noConncectionImageView.isHidden = true
            }
        }
    }
    
    
    //MARK: - Set up
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MuralCell.self, forCellWithReuseIdentifier: MuralCell.reuseID)
    }
    
    
    private func configureNoConnectionImage() {
        let config = UIImage.SymbolConfiguration(paletteColors: [.secondaryLabel])
        let image = UIImage(systemName: "wifi.exclamationmark")?.withConfiguration(config)
        noConncectionImageView.image = image
        noConncectionImageView.contentMode = .scaleAspectFit
        
        noConncectionImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noConncectionImageView)
        
        NSLayoutConstraint.activate([
            noConncectionImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 58),
            noConncectionImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            noConncectionImageView.widthAnchor.constraint(equalToConstant: 25),
            noConncectionImageView.heightAnchor.constraint(equalToConstant: 21),
        ])

        noConncectionImageView.isHidden = true
    }


    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Mural>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, mural) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MuralCell.reuseID, for: indexPath) as! MuralCell
            cell.set(imageURL: mural.thumbnailURL, imageType: .thumbnail, docRef: mural.docRef, uiImageViewSize: cell.bounds.size, reviewStatus: mural.reviewStatus)

            ImagesManager.shared.downloadImage(from: mural.imageURL, imageType: .fullSize, name: mural.docRef) { _ in }
            
            return cell
        })
    }
    
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Szukaj"
        searchController.searchBar.returnKeyType = .done
        navigationItem.searchController = searchController
    }
    
    
    //MARK: - Logic
    private func updateData(on murals: [Mural]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Mural>()
        snapshot.appendSections([.main])
        snapshot.appendItems(murals)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    
    private func iTShoudShowNoConnentivityAlert() -> Bool {
        guard let lastDate = NetworkMonitor.shared.lastTimeWhenNoConnentivityAlertWasShown else {
            NetworkMonitor.shared.lastTimeWhenNoConnentivityAlertWasShown = Date.now
            return true
        }
        
        let currentDate = Date.now
        let components = DateComponents(second: 40)
        guard let dateToCompare = Calendar.current.date(byAdding: components, to: lastDate) else { return false }
        
        if currentDate.compare(dateToCompare) == .orderedDescending {
            NetworkMonitor.shared.lastTimeWhenNoConnentivityAlertWasShown = Date.now
            return true
        } else {
            return false
        }
    }
    
    
    //MARK: - Actions
    @objc private func dismissVC() {
        navigationController?.dismiss(animated: true)
    }
    
    
    //MARK: - Binding
    private func addMuralsObserver() {
        if title == "Przeglądaj" {
            databaseManager.muralItems
                .subscribe(onNext: { [weak self] murals in
                    guard let self = self else { return }
                    self.murals = murals
                    self.updateData(on: self.murals)
                })
                .disposed(by: disposeBag)
        }
    }
    
    
    private func bindConnectionStatus() {
        NetworkMonitor.shared.connectionPublisher
            .subscribe(onNext: { isConnected in
                if !isConnected && self.deviceIsConnetedToInternet == true {
                    DispatchQueue.main.async {
                        self.deviceIsConnetedToInternet = false
                        self.noConncectionImageView.isHidden = false
                        NetworkMonitor.shared.lastTimeWhenNoConnentivityAlertWasShown = Date.now
                        self.presentMMAlert(message: MMMessages.noInternetConnection)
                    }
                } else if isConnected && self.deviceIsConnetedToInternet == false {
                    self.deviceIsConnetedToInternet = true
                    self.noConncectionImageView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
}


//MARK: - Ext: UICollectionViewDelegate
extension MuralsCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let muralItem = isSearching ? filteredMurals[indexPath.item] : murals[indexPath.item]
        selectedCell = collectionView.cellForItem(at: indexPath) as? MuralCell
        cellShape = .square
        setSnapshotsForAnimation()
        prepereAndPresentDetailVCWithAnimation(mural: muralItem, databaseManager: databaseManager)
    }
}


//MARK: - Ext: UISearchResultsUpdating
extension MuralsCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredMurals.removeAll()
            updateData(on: murals)
            isSearching = false
            return
        }
        
        isSearching = true
        filteredMurals = murals.filter {
            $0.address.lowercased().contains(filter.lowercased()) ||
            $0.author!.lowercased().contains(filter.lowercased()) ||
            $0.addedBy.lowercased().contains(filter.lowercased()) ||
            $0.city.lowercased().contains(filter.lowercased())
        }
        
        updateData(on: filteredMurals)
        
        if filteredMurals.isEmpty {
            showEmptyStateView(with: "Nie znaleziono żadnych murali spełniających kryteria wyszukiwania :(", in: view)
        } else {
            hideEmptyStateView(form: view)
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            if murals.isEmpty {
                showEmptyStateView(with: "Nie znaleziono żadnych murali spełniających kryteria wyszukiwania :(", in: view)
            } else {
                hideEmptyStateView(form: view)
            }
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
