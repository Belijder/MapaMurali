//
//  MostMuralCitiesVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 23/11/2022.
//

import UIKit
import RxSwift
import RxRelay

class MostMuralCitiesVC: UIViewController {
    
    //MARK: - Properities
    let disposeBag = DisposeBag()
    let cities = BehaviorRelay<[PopularCity]>(value: [])
    var statisticsViewModel: StatisticsViewModel!
    
    let titleLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    lazy var citiesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MMPopularCityTableViewCell.self, forCellReuseIdentifier: MMPopularCityTableViewCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.backgroundColor = .secondarySystemBackground
        tableView.layer.cornerRadius = 20
        tableView.separatorColor = .clear
        return tableView
    }()

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
        addCitiesObserver()
        bindTableView()
        titleLabel.text = "Najbardziej muralowe miasta"
    }

    
    //MARK: - Set up
    private func layoutUIElements() {
        citiesTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(titleLabel, citiesTableView)
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            citiesTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            citiesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            citiesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            citiesTableView.heightAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    
    //MARK: - Biding
    private func bindTableView() {
        cities
            .bind(to:
                    citiesTableView.rx.items(cellIdentifier: MMPopularCityTableViewCell.identifier, cellType: MMPopularCityTableViewCell.self)) { (row, city, cell) in
                cell.set(city: city)
            }
            .disposed(by: disposeBag)
        
        citiesTableView.rx.modelSelected(PopularCity.self).subscribe(onNext: { city in
            let murals = self.statisticsViewModel.databaseManager.murals.filter { $0.city == city.name }
            
            let destVC = MuralsCollectionViewController(databaseManager: self.statisticsViewModel.databaseManager)
            destVC.title = city.name
            destVC.murals = murals
            
            let navControler = UINavigationController(rootViewController: destVC)
            navControler.modalPresentationStyle = .fullScreen
            navControler.navigationBar.tintColor = MMColors.primary
            self.present(navControler, animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func addCitiesObserver() {
        statisticsViewModel.mostMuralCities
            .subscribe(onNext: { cities in
                self.cities.accept(cities)
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - Extensions
extension MostMuralCitiesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
