//
//  MostPopularMuralsVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 21/11/2022.
//

import UIKit
import RxSwift

class MostPopularMuralsVC: UIViewController {
    
    //MARK: - Live Cicle
    init(viewModel: StatisticsViewModel) {
        super.init(nibName: nil, bundle: nil)
//        self.databaseManager = databaseManager
        self.statisticsViewModel = viewModel
        print("🔵\(murals)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUIElements()
        addMuralObserver()
        bindCollectionView()
        titleLabel.text = "Najpopularniejsze Murale"
    }
    
    
    //MARK: - Properities
    
    
    let disposeBag = DisposeBag()
    let murals = BehaviorSubject<[Mural]>(value: [])
//    var databaseManager: DatabaseManager!
    var statisticsViewModel: StatisticsViewModel!
    
    let titleLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    lazy var collectionView: UICollectionView = {
        let padding: CGFloat = 20
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 160)
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MMFavoritesMuralCollectionCell.self, forCellWithReuseIdentifier: MMFavoritesMuralCollectionCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.layer.cornerRadius = 20
        return collectionView
    }()
    
    
    //MARK: - Setup UI
    func layoutUIElements() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(titleLabel, collectionView)
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            collectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    //MARK: - Biding
    private func bindCollectionView() {
        murals
            .bind(to:
                collectionView.rx.items(cellIdentifier: MMFavoritesMuralCollectionCell.identifier,
                                        cellType: MMFavoritesMuralCollectionCell.self)) { indexPath, mural, cell in
                cell.set(mural: mural)
            }
            .disposed(by: disposeBag)
    }
    
    func addMuralObserver() {
        statisticsViewModel.mostPopularMurals
            .subscribe(onNext: { murals in
                self.murals.onNext(murals)
            })
            .disposed(by: disposeBag)
    }
}

