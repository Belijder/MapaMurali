//
//  StatisticsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 24/10/2022.
//

import UIKit

class StatisticsViewController: UIViewController {

    //MARK: - Properieties
    let vm: StatisticsViewModel
    let mostPopularMuralsCollectionView = UIView()
    
    //MARK: - Live Cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Statystyki"
        layoutUI()
        configureCollectionsView()
        
    }
    
    
    //MARK: - Setup UI
    func layoutUI() {
        view.addSubviews(mostPopularMuralsCollectionView)
        mostPopularMuralsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mostPopularMuralsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mostPopularMuralsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mostPopularMuralsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mostPopularMuralsCollectionView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    func configureCollectionsView() {
        add(childVC: MostPopularMuralsVC(viewModel: vm), to: mostPopularMuralsCollectionView)
    }
    
    //MARK: - Buissness logic
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    //MARK: - Inicialization
    init(databaseManager: DatabaseManager) {
        self.vm = StatisticsViewModel(databaseManager: databaseManager)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
