//
//  MMCollectionViewTableViewCell.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 24/10/2022.
//

import UIKit
import RxSwift

protocol MMCollectionViewTableViewProtocol: AnyObject {
    func didSelectItemInCollectionView(muralItem: Mural)
}

class MMCollectionViewTableViewCell: UITableViewCell {
    
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Properities
    private let disposeBag = DisposeBag()
    var viewModel: MostPopularMuralsViewModel! {
        didSet {
            bindCollectionView()
        }
    }

    weak var delegate: MMCollectionViewTableViewProtocol?
    
    static let identifier = "MMCollectionViewTableViewCell"
    
    lazy var collectionView: UICollectionView = {
        let padding: CGFloat = 20
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 160)
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MMFavoritesMuralCollectionCell.self, forCellWithReuseIdentifier: MMFavoritesMuralCollectionCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    

    //MARK: - UI Setup
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        
        
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.layer.cornerRadius = 20
        
    }
    
    private func setupUI() {
        contentView.addSubview(collectionView)

    }
    
    //MARK: - Biding
    private func bindCollectionView() {
        viewModel.murals
            .bind(to:
                collectionView.rx.items(cellIdentifier: MMFavoritesMuralCollectionCell.identifier,
                                        cellType: MMFavoritesMuralCollectionCell.self)) { indexPath, mural, cell in
                cell.set(mural: mural)
            }
            .disposed(by: disposeBag)
    }
    

}

