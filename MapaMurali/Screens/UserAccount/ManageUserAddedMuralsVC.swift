//
//  ManageUserAddedMuralsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 14/11/2022.
//

import UIKit
import RxSwift
import RxRelay

class ManageUserAddedMuralsVC: MMDataLoadingVC {
    
    //MARK: - Properties
    private let databaseManager: DatabaseManager
    
    private var muralsTableView: UITableView!
    
    private var disposeBag = DisposeBag()
    private var observableMurals = BehaviorRelay<[Mural]>(value: [])
    
    private var userAddedMurals: [Mural] {
        didSet {
            let sortedMurals = userAddedMurals.sorted { $0.addedDate > $1.addedDate }
            self.observableMurals.accept(sortedMurals)
        }
    }
    
    
    //MARK: - Inicialization
    init(databaseManager: DatabaseManager, userAddedMurals: [Mural]) {
        self.databaseManager = databaseManager
        self.userAddedMurals = userAddedMurals
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = MMColors.primary
        
        addDatabaseMuralsObserver()
        configureMuralTableView()
        bindTableView()
        self.observableMurals.accept(userAddedMurals)
        
        if userAddedMurals.isEmpty {
            showEmptyStateView(with: "Nie masz żadnych dodanych murali. Idź na spacer i zrób kilka fotek :)", in: view)
        }
    }
    
    
    //MARK: - Set up
    private func configureMuralTableView() {
        muralsTableView = UITableView(frame: view.bounds)
        view.addSubview(muralsTableView)
        muralsTableView.delegate = self
        muralsTableView.backgroundColor = .systemBackground
        muralsTableView.register(MMUserAddedMuralTableViewCell.self, forCellReuseIdentifier: MMUserAddedMuralTableViewCell.identifier)
    }
    
    
    //MARK: - Biding
    private func bindTableView() {
        observableMurals
            .bind(to: muralsTableView.rx.items(cellIdentifier: MMUserAddedMuralTableViewCell.identifier, cellType: MMUserAddedMuralTableViewCell.self)) { (row, mural, cell) in
                cell.set(from: mural)
                cell.muralImageView.layer.cornerRadius = 10
            }
            .disposed(by: disposeBag)
        
        muralsTableView.rx.modelSelected(Mural.self)
            .subscribe(onNext: { [weak self] mural in
                guard let self = self else { return }
                let destVC = MuralDetailsViewController(muralItem: mural, databaseManager: self.databaseManager, presentingVCTitle: self.title)
                destVC.modalPresentationStyle = .fullScreen
                self.present(destVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
    private func addDatabaseMuralsObserver() {
        databaseManager.muralItems
            .subscribe(onNext: { [weak self] murals in
                guard let self = self else { return }
                let userAddedMurals = murals.filter { $0.addedBy == self.databaseManager.currentUser?.id }
                let sortedMurals = userAddedMurals.sorted { $0.addedDate > $1.addedDate }
                self.userAddedMurals = sortedMurals
            })
            .disposed(by: disposeBag)
    }
}


//MARK: - Extensions
extension ManageUserAddedMuralsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let muralID = self.userAddedMurals[indexPath.row].docRef
        
        let editAction = UIContextualAction(style: .normal, title: "Edytuj") { _, _, completed in
            let destVC = EditMuralViewController(mural: self.userAddedMurals[indexPath.row], databaseManager: self.databaseManager)
            let navControler = UINavigationController(rootViewController: destVC)
            navControler.modalPresentationStyle = .fullScreen
            self.present(navControler, animated: true)

            completed(true)
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Usuń") { _, _, completed in
            guard NetworkMonitor.shared.isConnected == true else {
                self.presentMMAlert(title: "Brak połączenia", message: MMError.noConnectionDefaultMessage.rawValue)
                completed(false)
                return
            }
            
            let muralReviewStatus = self.userAddedMurals[indexPath.row].reviewStatus
            
            self.databaseManager.removeMural(for: muralID) { success in
                if success == true {
                    self.databaseManager.lastDeletedMuralID.onNext(muralID)
                    if let userID = self.databaseManager.currentUser?.id {
                        if muralReviewStatus > 0 {
                            self.databaseManager.changeNumberOfMuralsAddedBy(user: userID, by: -1)
                        }
                    }
                    completed(true)
                } else {
                    completed(false)
                }
            }
            self.databaseManager.murals.removeAll(where: { $0.docRef == muralID })
        }

        editAction.image = UIImage(systemName: "square.and.pencil")
        editAction.backgroundColor = .systemYellow
        deleteAction.image = UIImage(systemName: "trash")

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return swipeActions
    }
}
