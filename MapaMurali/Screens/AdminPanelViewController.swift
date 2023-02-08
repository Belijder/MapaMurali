//
//  AdminPanelViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 07/02/2023.
//

import UIKit
import RxSwift
import RxRelay

class AdminPanelViewController: MMDataLoadingVC {
    
    // MARK: - Properties
    private let databaseManager: DatabaseManager
    private var muralsTableView: UITableView!
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
        navigationController?.navigationBar.tintColor = MMColors.primary
        
        configureMuralTableView()
        bindTableView()
    }
    
    
    // MARK: - Set up
    private func configureMuralTableView() {
        muralsTableView = UITableView(frame: view.bounds)
        view.addSubview(muralsTableView)
        muralsTableView.delegate = self
        muralsTableView.backgroundColor = .systemBackground
        muralsTableView.register(MMUserAddedMuralTableViewCell.self, forCellReuseIdentifier: MMUserAddedMuralTableViewCell.identifire)
    }
    
    
    //MARK: - Biding
    private func bindTableView() {
        databaseManager.unreviewedMuralsPublisher
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
        databaseManager.unreviewedMuralsPublisher
            .subscribe(onNext: { [weak self] murals in
                guard let self = self else { return }
                
                if murals.isEmpty {
                    self.showEmptyStateView(with: "Nie masz żadnych murali do zaakceptowania.", in: self.view)
                }
            })
            .disposed(by: disposeBag)
    }
}


//MARK: - Extensions
extension AdminPanelViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let muralID = self.databaseManager.unreviewedMurals[indexPath.row].docRef
        
        let acceptAction = UIContextualAction(style: .normal, title: "Zaakceptuj") { _, _, completed in
            print("🟢 Mural zaakceptowano.")
            self.databaseManager.acceptMural(muralID: muralID)
            
            completed(true)
        }
        
        let rejectAction = UIContextualAction(style: .destructive, title: "Usuń") { _, _, completed in
            print("🔴 Mural odrzucono.")
            
            self.databaseManager.removeMural(for: muralID) { success in
                if success == true {
                    self.databaseManager.lastDeletedMuralID.onNext(muralID)
                    completed(true)
                } else {
                    completed(false)
                }
            }
            self.databaseManager.murals.removeAll(where: { $0.docRef == muralID })
            self.databaseManager.unreviewedMurals.removeAll { $0.docRef == muralID }
        }
        
        acceptAction.image = UIImage(systemName: "checkmark")
        acceptAction.backgroundColor = .systemGreen
        rejectAction.image = UIImage(systemName: "xmark")
        
        let swipeActions = UISwipeActionsConfiguration(actions: [rejectAction, acceptAction])
        return swipeActions
    }
}
