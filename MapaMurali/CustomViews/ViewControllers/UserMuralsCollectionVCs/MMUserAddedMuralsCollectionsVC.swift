//
//  MMUserAddedMuralsCollectionsVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 12/11/2022.
//

import UIKit

protocol MMUserAddedMuralsCollectionsDelegate: AnyObject {
    func didTapManageAddedMurals()
    func didSelectUserAddedMural(at index: Int)

}

class MMUserAddedMuralsCollectionsVC: MMUserMuralsCollectionsVC {
    
    weak var delegate: MMUserAddedMuralsCollectionsDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }

    init(collectionName: String, murals: [Mural], delegate: MMUserAddedMuralsCollectionsDelegate) {
        super.init(collectionTitle: collectionName, murals: murals)
        self.delegate = delegate
    }
    
    private func configureItems() {
        self.actionButton.set(color: .systemBlue, title: "Zarządzaj")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func actionButtonTapped() {
        delegate.didTapManageAddedMurals()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.didSelectUserAddedMural(at: indexPath.row)
    }
}
