//
//  MMUserAddedMuralsCollectionsVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 12/11/2022.
//

import UIKit

class MMUserAddedMuralsCollectionsVC: MMUserMuralsCollectionsVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }

    init(collectionName: String, murals: [Mural], databaseManager: DatabaseManager) {
        super.init(collectionTitle: collectionName, murals: murals, databaseManager: databaseManager)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userAddedMurals = databaseManager.murals.filter { $0.addedBy == databaseManager.currentUser?.id }
        murals = userAddedMurals
        updateData(on: murals)
    }
    
    private func configureItems() {
        self.actionButton.set(color: MMColors.primary, title: "Zarządzaj")
        self.emptyStateLabel.text = "Nie dodałeś jeszcze żadnych murali."
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func actionButtonTapped() {
        print("🟢 Manage User Added Murals Button Tapped!")
        let destVC = ManageUserAddedMuralsVC(databaseManager: databaseManager, userAddedMurals: murals)
        destVC.title = "Zarządzaj muralami"
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destVC = MuralDetailsViewController(muralItem: murals[indexPath.row], databaseManager: databaseManager)
        destVC.title = murals[indexPath.row].adress
        let navControler = UINavigationController(rootViewController: destVC)
        navControler.modalPresentationStyle = .fullScreen
        self.present(navControler, animated: true)
    }
}
