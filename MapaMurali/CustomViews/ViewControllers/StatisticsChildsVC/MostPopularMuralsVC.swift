//
//  MostPopularMuralsVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 21/11/2022.
//

import UIKit
import RxSwift
import RxRelay

class MostPopularMuralsVC: MMAnimableViewController {
    
    //MARK: - Properities
    private var disposeBag = DisposeBag()
    
    private let murals = BehaviorRelay<[Mural]>(value: [])
    private var statisticsViewModel: StatisticsViewModel!
    
    private let titleLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    lazy private var collectionView: UICollectionView = {
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
    
    
    //MARK: - Initialization
    init(viewModel: StatisticsViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.statisticsViewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    
    //MARK: - Live Cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUIElements()
        addMuralObserver()
        bindCollectionView()
        titleLabel.text = "Najpopularniejsze Murale"
    }
    
    
    //MARK: - Set up
    private func layoutUIElements() {
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
                cell.set(mural: mural, uiImageViewSize: CGSize(width: 120, height: 120))
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let self = self else { return }
            self.selectedCell = self.collectionView.cellForItem(at: index) as? MMFavoritesMuralCollectionCell
            self.cellShape = .circle(radius: RadiusValue.muralCellRadiusValue)
            self.setSnapshotsForAnimation()
        })
        .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Mural.self).subscribe(onNext: { [weak self] mural in
            guard let self = self else { return }
            self.prepereAndPresentDetailVCWithAnimation(mural: mural, databaseManager: self.statisticsViewModel.databaseManager)
        }).disposed(by: disposeBag)
    }
    
    private func addMuralObserver() {
        statisticsViewModel.mostPopularMurals
            .subscribe(onNext: { murals in
                self.murals.accept(murals)
            })
            .disposed(by: disposeBag)
    }
}
