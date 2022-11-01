//
//  StatisticsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 24/10/2022.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    let databaseManager: DatabaseManager
    
    private let headers = ["Najpopularniejsze murale", "Najaktywniejsi użytkownicy", "Najbardziej muralowe Miasta"]
    
    private let statisticTableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(MMCollectionViewTableViewCell.self, forCellReuseIdentifier: MMCollectionViewTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Statystyki"
        view.addSubview(statisticTableView)

        statisticTableView.delegate = self
        statisticTableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statisticTableView.frame = view.bounds
    }
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
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
            cell.set(murals: databaseManager.murals)
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
            return 80.0
        case 2:
            return 120.0
        default:
            return 10.0
        }
    }
}

extension StatisticsViewController: MMCollectionViewTableViewProtocol {
    func didSelectItemInCollectionView(muralItem: Mural) {
        let destVC = MuralDetailsViewController(muralItem: muralItem, databaseManager: databaseManager)
        destVC.title = muralItem.adress
        let navControler = UINavigationController(rootViewController: destVC)
        navControler.modalPresentationStyle = .fullScreen
        self.present(navControler, animated: true)
    }
    
    
}
