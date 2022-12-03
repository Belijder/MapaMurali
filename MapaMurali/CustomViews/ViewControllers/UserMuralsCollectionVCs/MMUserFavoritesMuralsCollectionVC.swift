//
//  MMUserFavoritesMuralsCollectionVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 13/11/2022.
//

import UIKit

class MMUserFavoritesMuralsCollectionVC: MMUserMuralsCollectionsVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()

    }
    
    init(colectionName: String, murals: [Mural], databaseManager: DatabaseManager) {
        super.init(collectionTitle: colectionName, murals: murals, databaseManager: databaseManager)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let user = databaseManager.currentUser {
            let userFavoriteMurals = databaseManager.murals.filter { user.favoritesMurals.contains($0.docRef) }
            self.murals = userFavoriteMurals
            updateData(on: murals)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureItems() {
        actionButton.set(color: MMColors.primary, title: "Przeglądaj")
        self.emptyStateLabel.text = "Nie masz jeszcze ulubionych murali."
    }
    
    override func actionButtonTapped() {
        print("🟢 Browse User Favorites Murals Button Tapped!")
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destVC = MuralDetailsViewController(muralItem: murals[indexPath.row], databaseManager: databaseManager)
        destVC.title = murals[indexPath.row].adress
        let navControler = UINavigationController(rootViewController: destVC)
        navControler.modalPresentationStyle = .fullScreen
        self.present(navControler, animated: true)

    }
}
