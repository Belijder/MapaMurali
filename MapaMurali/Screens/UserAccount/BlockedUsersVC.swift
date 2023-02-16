//
//  BlockedUsersVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 14/02/2023.
//

import UIKit
import RxSwift

class BlockedUsersVC: MMDataLoadingVC {
    
    // MARK: - Properties
    private var muralsTableView: UITableView!
    private let databaseManager: DatabaseManager
    private var disposeBag = DisposeBag()


    // MARK: - Initialization
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    
    // MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(self.dismissVC))
        navigationItem.leftBarButtonItem = backButton
        configureBlockedUsersTableView()
        bindBlockedUsersTableView()
        addBlockedUsersObserver()
    }
    
    
    // MARK: - Set up
    private func configureBlockedUsersTableView() {
        muralsTableView = UITableView(frame: view.bounds)
        view.addSubview(muralsTableView)
        muralsTableView.delegate = self
        muralsTableView.backgroundColor = .systemBackground
        muralsTableView.register(MMBlockedUserTableViewCell.self, forCellReuseIdentifier: MMBlockedUserTableViewCell.identifier)
    }
    
    
    // MARK: - Actions
    @objc private func dismissVC() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    //MARK: - Biding
    private func bindBlockedUsersTableView() {
        databaseManager.blockedUsersPublisher
            .bind(to: muralsTableView.rx.items(cellIdentifier: MMBlockedUserTableViewCell.identifier, cellType: MMBlockedUserTableViewCell.self)) { (row, userID, cell) in
                self.databaseManager.fetchUserFromDatabase(id: userID) { result in
                    switch result {
                    case .success(let user):
                    cell.set(from: user)
                    cell.delegate = self
                    case .failure(_):
                        break
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    private func addBlockedUsersObserver() {
        databaseManager.blockedUsersPublisher
            .subscribe(onNext: { [weak self] users in
                guard let self = self else { return }
                
                if users.isEmpty {
                    self.showEmptyStateView(with: "Nie masz żadnych zablokowanych użytkowników.", in: self.view)
                }
            })
            .disposed(by: disposeBag)
    }
}


//MARK: - Extensions
extension BlockedUsersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}


extension BlockedUsersVC: MMBlockedUserCellDelegate {
    func unblockButtonTappedFor(userID: String) {
        databaseManager.unblockUserContent(userID: userID) { success in
            if success {
                self.presentMMAlert(title: "Udało się!", message: "Użytkownik został odblokowany. Znów możesz przeglądać treści dodane przez tego użytkownika.", buttonTitle: "OK")
            }
        }
    }
}
