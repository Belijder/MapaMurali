//
//  StatisticsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 24/10/2022.
//

import UIKit

class StatisticsViewController: UIViewController {

    let vm: StatisticsViewModel
    
    private let headers = ["Najpopularniejsze murale", "Najaktywniejsi użytkownicy", "Najbardziej muralowe Miasta"]
    
    private let statisticTableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(MMCollectionViewTableViewCell.self, forCellReuseIdentifier: MMCollectionViewTableViewCell.identifier)
        table.register(MMUsersTableViewInTableViewCell.self, forCellReuseIdentifier: MMUsersTableViewInTableViewCell.identifier)
        table.register(MMPopularCitiesTableViewCell.self, forCellReuseIdentifier: MMPopularCitiesTableViewCell.identifier)
        table.separatorColor = .clear
        table.showsVerticalScrollIndicator = false
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Statystyki"
        view.addSubview(statisticTableView)
        vm.createMostPopularMuralsArray()
        vm.createPopularCitiesArray()
        statisticTableView.delegate = self
        statisticTableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statisticTableView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    init(databaseManager: DatabaseManager) {
        self.vm = StatisticsViewModel(databaseManager: databaseManager)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = statisticTableView.dequeueReusableCell(withIdentifier: MMCollectionViewTableViewCell.identifier, for: indexPath) as! MMCollectionViewTableViewCell
            cell.set(murals: vm.mostPopularMurals)
            cell.delegate = self
            return cell
            
        case 1:
            let cell = statisticTableView.dequeueReusableCell(withIdentifier: MMUsersTableViewInTableViewCell.identifier) as! MMUsersTableViewInTableViewCell
            let sortedUsers = vm.databaseManager.users.sorted { $0.muralsAdded > $1.muralsAdded }
            cell.set(users: sortedUsers)
            cell.delegate = self
            return cell
            
        case 2:
            let cell = statisticTableView.dequeueReusableCell(withIdentifier: MMPopularCitiesTableViewCell.identifier) as! MMPopularCitiesTableViewCell
            cell.set(cities: vm.popularCities)
            cell.delegate = self
            return cell
        default:
            let cell = statisticTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        } 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headers.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 220.0
        case 1:
            return 180.0
        case 2:
            return 180.0
        default:
            return 10.0
        }
    }
}

extension StatisticsViewController: MMCollectionViewTableViewProtocol, MMUsersTableViewInTableViewDelegate, MMPopularCitiesTableViewProtocol {
    func didSelectRowWithCityName(city: String) {
        let murals = vm.databaseManager.murals.filter { $0.city == city }
        let destVC = MuralsCollectionViewController(databaseManager: vm.databaseManager)
        destVC.murals = murals
        destVC.title = city
        navigationController?.navigationBar.tintColor = MMColors.primary
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    func didSelectRowWith(user: User) {
        let murals = vm.databaseManager.murals.filter { $0.addedBy == user.id }
        let destVC = MuralsCollectionViewController(databaseManager: vm.databaseManager)
        destVC.murals = murals
        destVC.title = user.displayName
        navigationController?.navigationBar.tintColor = MMColors.primary
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    func didSelectItemInCollectionView(muralItem: Mural) {
        let destVC = MuralDetailsViewController(muralItem: muralItem, databaseManager: vm.databaseManager)
        destVC.title = muralItem.adress
        let navControler = UINavigationController(rootViewController: destVC)
        navControler.modalPresentationStyle = .fullScreen
        self.present(navControler, animated: true)
    }
    
    
}
