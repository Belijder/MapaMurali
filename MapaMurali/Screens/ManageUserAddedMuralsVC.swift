//
//  ManageUserAddedMuralsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 14/11/2022.
//

import UIKit
import RxSwift
import RxRelay

class ManageUserAddedMuralsVC: UIViewController {
    
    let databaseManager: DatabaseManager
    let disposeBag = DisposeBag()
    
    var userAddedMurals: [Mural] {
        didSet {
            self.observableMurals.accept(userAddedMurals)
        }
    }
    
    var observableMurals = BehaviorRelay<[Mural]>(value: [])
    
    var muralsTableView: UITableView!
    
    init(databaseManager: DatabaseManager, userAddedMurals: [Mural]) {
        self.databaseManager = databaseManager
        self.userAddedMurals = userAddedMurals
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = MMColors.primary
        
        addDatabaseMuralsObserver()
        configureMuralTableView()
        bindTableView()
        self.observableMurals.accept(userAddedMurals)
        
    }
    
    func configureMuralTableView() {
        muralsTableView = UITableView(frame: view.bounds)
        view.addSubview(muralsTableView)
        muralsTableView.delegate = self
        muralsTableView.backgroundColor = .systemBackground
        muralsTableView.register(MMUserAddedMuralTableViewCell.self, forCellReuseIdentifier: MMUserAddedMuralTableViewCell.identifire)
    }
    
    
    //MARK: - Biding
    func bindTableView() {
        observableMurals
            .bind(to: muralsTableView.rx.items(cellIdentifier: MMUserAddedMuralTableViewCell.identifire, cellType: MMUserAddedMuralTableViewCell.self)) { (row, mural, cell) in
                cell.set(from: mural)
                cell.muralImageView.layer.cornerRadius = 10
            }
            .disposed(by: disposeBag)
        
        muralsTableView.rx.modelSelected(Mural.self)
            .subscribe(onNext: { mural in
                let destVC = MuralDetailsViewController(muralItem: mural, databaseManager: self.databaseManager)
                destVC.title = mural.adress
                let navControler = UINavigationController(rootViewController: destVC)
                navControler.modalPresentationStyle = .fullScreen
                self.present(navControler, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func addDatabaseMuralsObserver() {
        databaseManager.muralItems
            .subscribe(onNext: { murals in
                let userAddedMurals = murals.filter { $0.addedBy == self.databaseManager.currentUser?.id }
                self.userAddedMurals = userAddedMurals
            })
            .disposed(by: disposeBag)
    }
}

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
            self.userAddedMurals.remove(at: indexPath.row)
            print("🟡 Mural Was removed from userAddedMurals, and row in tableView has been deleted also.")
        }

        editAction.image = UIImage(systemName: "square.and.pencil")
        editAction.backgroundColor = .systemYellow
        deleteAction.image = UIImage(systemName: "trash")

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return swipeActions
    }
}
