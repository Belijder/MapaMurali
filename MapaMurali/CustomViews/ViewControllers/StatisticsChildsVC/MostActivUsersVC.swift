//
//  MostActivUsersVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 23/11/2022.
//

import UIKit
import RxSwift
import RxRelay

class MostActivUsersVC: UIViewController {

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
        addUserObserver()
        bindTableView()
        titleLabel.text = "Najaktywniejsi użytkownicy"
    }
    
    
    //MARK: - Properities
    let disposeBag = DisposeBag()
    let users = BehaviorRelay<[User]>(value: [])
    var statisticsViewModel: StatisticsViewModel!
    
    let titleLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    lazy var usersTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MMMostActivUsersCell.self, forCellReuseIdentifier: MMMostActivUsersCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.backgroundColor = .secondarySystemBackground
        tableView.layer.cornerRadius = 20
        tableView.separatorColor = .clear
        return tableView
    }()
    

    //MARK: - Setup UI
    private func layoutUIElements() {
        usersTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(titleLabel, usersTableView)
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            usersTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            usersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            usersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            usersTableView.heightAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    //MARK: - Biding
    private func bindTableView() {
        users
            .bind(to:
                    usersTableView.rx.items(cellIdentifier: MMMostActivUsersCell.identifier, cellType: MMMostActivUsersCell.self)) { (row, user, cell) in
                cell.set(user: user)
            }
            .disposed(by: disposeBag)
        
        usersTableView.rx.modelSelected(User.self).subscribe(onNext: { user in
            let userAddedMural = self.statisticsViewModel.databaseManager.murals.filter { $0.addedBy == user.id }
            
            let destVC = MuralsCollectionViewController(databaseManager: self.statisticsViewModel.databaseManager)
            destVC.title = user.displayName
            destVC.murals = userAddedMural
            
            self.navigationController?.navigationBar.tintColor = MMColors.primary
            self.navigationController?.pushViewController(destVC, animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func addUserObserver() {
        statisticsViewModel.mostActivUsers
            .subscribe(onNext: { users in
                self.users.accept(users)
            })
            .disposed(by: disposeBag)
    }
}

extension MostActivUsersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
