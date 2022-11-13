//
//  MMUserFavoritesMuralsCollectionVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 13/11/2022.
//

import UIKit

protocol MMUserFavoritesMuralsCollectionDelegate: AnyObject {
    func didTapedBrowseButton()
    func didSelectUserFavoriteMural(at index: Int)
}

class MMUserFavoritesMuralsCollectionVC: MMUserMuralsCollectionsVC {
    
    weak var delegate: MMUserFavoritesMuralsCollectionDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()

    }
    
    init(colectionName: String, murals: [Mural], delegate: MMUserFavoritesMuralsCollectionDelegate) {
        super.init(collectionTitle: colectionName, murals: murals)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureItems() {
        actionButton.set(color: .systemBlue, title: "Przeglądaj")
    }
    
    override func actionButtonTapped() {
        delegate.didTapedBrowseButton()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.didSelectUserFavoriteMural(at: indexPath.row)
    }
    
    
    
}
