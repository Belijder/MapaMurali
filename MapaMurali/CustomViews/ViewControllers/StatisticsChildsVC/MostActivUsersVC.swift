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
    
    //MARK: - Properities
    private var disposeBag = DisposeBag()
    private let users = BehaviorRelay<[User]>(value: [])
    private var statisticsViewModel: StatisticsViewModel!
    private let titleLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    lazy private var usersTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MMMostActivUsersCell.self, forCellReuseIdentifier: MMMostActivUsersCell.identifier)
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
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    
    //MARK: - Live Cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUIElements()
        addUserObserver()
        bindTableView()
        titleLabel.text = "Najaktywniejsi użytkownicy"
    }
    

    //MARK: - Set up
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
        
        usersTableView.rx.modelSelected(User.self).subscribe(onNext: { [weak self] user in
            guard let self = self else { return }
            let userAddedMural = self.statisticsViewModel.databaseManager.murals.filter { $0.addedBy == user.id }
            
            let destVC = MuralsCollectionViewController(databaseManager: self.statisticsViewModel.databaseManager)
            destVC.title = user.displayName
            destVC.murals = userAddedMural
            
            let navControler = UINavigationController(rootViewController: destVC)
            navControler.modalPresentationStyle = .fullScreen
            navControler.navigationBar.tintColor = MMColors.primary
            self.present(navControler, animated: true)
            
        }).disposed(by: disposeBag)
    }
    
    
    private func addUserObserver() {
        statisticsViewModel.mostActivUsers
            .subscribe(onNext: { [weak self] users in
                guard let self = self else { return }
                self.users.accept(users)
            })
            .disposed(by: disposeBag)
    }
}


//MARK: - Extensions
extension MostActivUsersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
