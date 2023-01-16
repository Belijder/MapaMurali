//
//  MostPopularMuralsVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 21/11/2022.
//

import UIKit
import RxSwift
import RxRelay

class MostPopularMuralsVC: UIViewController {
    
    //MARK: - Initialization
    init(viewModel: StatisticsViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.statisticsViewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Live Cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUIElements()
        addMuralObserver()
        bindCollectionView()
        titleLabel.text = "Najpopularniejsze Murale"
    }
    
    
    //MARK: - Properities
    let disposeBag = DisposeBag()
    let murals = BehaviorRelay<[Mural]>(value: [])
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
    
    
    //MARK: - Set up
    func layoutUIElements() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(titleLabel, collectionView)
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
        
        collectionView.rx.modelSelected(Mural.self).subscribe(onNext: { mural in
            let destVC = MuralDetailsViewController(muralItem: mural, databaseManager: self.statisticsViewModel.databaseManager)
            destVC.modalPresentationStyle = .fullScreen
            self.present(destVC, animated: true)
        }).disposed(by: disposeBag)
    }
    
    func addMuralObserver() {
        statisticsViewModel.mostPopularMurals
            .subscribe(onNext: { murals in
                self.murals.accept(murals)
            })
            .disposed(by: disposeBag)
    }
}

