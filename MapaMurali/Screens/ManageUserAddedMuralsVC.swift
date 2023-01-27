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
            self.observableMurals.accept(userAddedMurals)
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
        muralsTableView.register(MMUserAddedMuralTableViewCell.self, forCellReuseIdentifier: MMUserAddedMuralTableViewCell.identifire)
    }
    
    
    //MARK: - Biding
    private func bindTableView() {
        observableMurals
            .bind(to: muralsTableView.rx.items(cellIdentifier: MMUserAddedMuralTableViewCell.identifire, cellType: MMUserAddedMuralTableViewCell.self)) { (row, mural, cell) in
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
                self.userAddedMurals = userAddedMurals
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
            print("🟡 Edit Swipe Action Tapped")
            let destVC = EditMuralViewController(mural: self.userAddedMurals[indexPath.row], databaseManager: self.databaseManager)
            let navControler = UINavigationController(rootViewController: destVC)
            navControler.modalPresentationStyle = .fullScreen
            self.present(navControler, animated: true)

            completed(true)
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Usuń") { _, _, completed in
            print("🟡 Remove Swipe Action Tapped")
            self.databaseManager.removeMural(for: muralID) { success in
                if success == true {
                    print("🟢 Mural was succesfully deleted from database.")
                    self.databaseManager.lastDeletedMuralID.onNext(muralID)
                    completed(true)
                } else {
                    print("🔴 Try to delete mural from database faild.")
                    completed(false)
                }
            }
            self.databaseManager.murals.removeAll(where: { $0.docRef == muralID })
            print("🟡 Mural Was removed from userAddedMurals, and row in tableView has been deleted also.")
        }

        editAction.image = UIImage(systemName: "square.and.pencil")
        editAction.backgroundColor = .systemYellow
        deleteAction.image = UIImage(systemName: "trash")

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return swipeActions
    }
}
