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
    
    var animator: Animator?
    
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
        
        collectionView.rx.itemSelected.subscribe(onNext: { index in
            print("🟡 Item Selected subsriber run")
            self.selectedCell = self.collectionView.cellForItem(at: index) as? MMFavoritesMuralCollectionCell
            self.selectedCellImageViewSnapshot = self.selectedCell?.muralImageView.snapshotView(afterScreenUpdates: false)
            self.windowSnapshot = self.view.window?.snapshotView(afterScreenUpdates: false)
        })
        .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Mural.self).subscribe(onNext: { mural in
            print("🟡 Model Selected subsriber run")
            self.showLoadingView(message: nil)
            
            let destVC = MuralDetailsViewController(muralItem: mural, databaseManager: self.statisticsViewModel.databaseManager)
            destVC.modalPresentationStyle = .fullScreen
            destVC.transitioningDelegate = self
            
            NetworkManager.shared.downloadImage(from: mural.imageURL, imageType: .fullSize, name: mural.docRef) { image in
                DispatchQueue.main.async {
                    destVC.imageView.image = image
                    self.dismissLoadingView()
                    self.present(destVC, animated: true)
                }
            }
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

extension MostPopularMuralsVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        guard let muralsCollectionVC = source as? MMAnimableViewController,
              let muralDetailsVC = presented as? MuralDetailsViewController,
              let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot,
              let windowSnapshot = windowSnapshot
        else {
            return nil
        }

        animator = Animator(type: .present, firstViewController: muralsCollectionVC, secondViewController: muralDetailsVC, selectedCellImageSnapshot: selectedCellImageViewSnapshot, windowSnapshot: windowSnapshot)
        
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let muralDetailsVC = dismissed as? MuralDetailsViewController,
              let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot,
              let windowSnapshot = windowSnapshot
        else { return nil }

        animator = Animator(type: .dismiss, firstViewController: self, secondViewController: muralDetailsVC, selectedCellImageSnapshot: selectedCellImageViewSnapshot, windowSnapshot: windowSnapshot)

        return animator
    }
}

