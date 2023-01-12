//
//  MMUserFavoritesMuralsCollectionVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 13/11/2022.
//

import UIKit

class MMUserFavoritesMuralsCollectionVC: MMUserMuralsCollectionsVC {
    
    //MARK: - Initialization
    init(colectionName: String, murals: [Mural], databaseManager: DatabaseManager) {
        super.init(collectionTitle: colectionName, murals: murals, databaseManager: databaseManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let user = databaseManager.currentUser {
            let userFavoriteMurals = databaseManager.murals.filter { user.favoritesMurals.contains($0.docRef) }
            self.murals = userFavoriteMurals
            updateData(on: murals)
        }
    }
    
    //MARK: - Set up
    func configureItems() {
        self.actionButton.text = "Przeglądaj"
        self.actionButton.textColor = MMColors.primary
        self.emptyStateLabel.text = "Nie masz jeszcze ulubionych murali."
        
    }
    
    //MARK: - Actions
    override func actionButtonTapped() {
        print("🟢 Browse User Favorites Murals Button Tapped!")
        let destVC = MuralsCollectionViewController(databaseManager: databaseManager)
        destVC.murals = murals
        destVC.title = "Ulubione murale"
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    //MARK: - Extensions
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destVC = MuralDetailsViewController(muralItem: murals[indexPath.row], databaseManager: databaseManager)
        destVC.title = murals[indexPath.row].adress
        let navControler = UINavigationController(rootViewController: destVC)
        navControler.modalPresentationStyle = .fullScreen
        self.present(navControler, animated: true)

    }
}
