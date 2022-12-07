//
//  StatisticsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 24/10/2022.
//

import UIKit

class StatisticsViewController: UIViewController {

    //MARK: - Properties
    let vm: StatisticsViewModel
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let mostPopularMuralsCollectionView = UIView()
    let mostActivUsersView = UIView()
    let mostMuralCitiesView = UIView()
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Statystyki"
        configureScrollView()
        layoutUI()
        configureCollectionsView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    
    //MARK: - Set up
    func layoutUI() {
        
        contentView.addSubviews(mostPopularMuralsCollectionView, mostActivUsersView, mostMuralCitiesView)
        mostPopularMuralsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        mostActivUsersView.translatesAutoresizingMaskIntoConstraints = false
        mostMuralCitiesView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mostPopularMuralsCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mostPopularMuralsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mostPopularMuralsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mostPopularMuralsCollectionView.heightAnchor.constraint(equalToConstant: 230),
            
            mostActivUsersView.topAnchor.constraint(equalTo: mostPopularMuralsCollectionView.bottomAnchor, constant: 30),
            mostActivUsersView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mostActivUsersView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mostActivUsersView.heightAnchor.constraint(equalToConstant: 190),
            
            mostMuralCitiesView.topAnchor.constraint(equalTo: mostActivUsersView.bottomAnchor, constant: 30),
            mostMuralCitiesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mostMuralCitiesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mostMuralCitiesView.heightAnchor.constraint(equalToConstant: 190)
            
        ])
    }
    
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.pinToEdges(of: view)
        scrollView.showsVerticalScrollIndicator = false
        contentView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 700)
        ])

    }
    
    func configureCollectionsView() {
        add(childVC: MostPopularMuralsVC(viewModel: vm), to: mostPopularMuralsCollectionView)
        add(childVC: MostActivUsersVC(viewModel: vm), to: mostActivUsersView)
        add(childVC: MostMuralCitiesVC(viewModel: vm), to: mostMuralCitiesView)
    }
    
    //MARK: -  Logic
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
