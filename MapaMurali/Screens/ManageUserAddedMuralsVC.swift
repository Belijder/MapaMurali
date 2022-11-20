//
//  ManageUserAddedMuralsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 14/11/2022.
//

import UIKit

class ManageUserAddedMuralsVC: UIViewController {
    
    let databaseManager: DatabaseManager
    var userAddedMurals: [Mural]
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
        configureMuralTableView()
        
    }
    
    func configureMuralTableView() {
        muralsTableView = UITableView(frame: view.bounds)
        view.addSubview(muralsTableView)
        muralsTableView.delegate = self
        muralsTableView.dataSource = self
        muralsTableView.backgroundColor = .systemBackground
        muralsTableView.register(MMUserAddedMuralTableViewCell.self, forCellReuseIdentifier: MMUserAddedMuralTableViewCell.identifire)
    }

}

extension ManageUserAddedMuralsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userAddedMurals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = muralsTableView.dequeueReusableCell(withIdentifier: MMUserAddedMuralTableViewCell.identifire) as! MMUserAddedMuralTableViewCell
        cell.set(from: userAddedMurals[indexPath.row])
        cell.muralImageView.layer.cornerRadius = 10
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destVC = MuralDetailsViewController(muralItem: userAddedMurals[indexPath.row], databaseManager: databaseManager)
        destVC.title = userAddedMurals[indexPath.row].adress
        let navControler = UINavigationController(rootViewController: destVC)
        navControler.modalPresentationStyle = .fullScreen
        self.present(navControler, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let muralID = self.userAddedMurals[indexPath.row].docRef
        
        let editAction = UIContextualAction(style: .normal, title: "Edytuj") { _, _, completed in
            print("🟡 Edit Swipe Action Tapped")
            
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
            tableView.deleteRows(at: [indexPath], with: .fade)
            print("🟡 Mural Was removed from userAddedMurals, and row in tableView has been deleted also.")
        }
        
        editAction.image = UIImage(systemName: "square.and.pencil")
        editAction.backgroundColor = .systemYellow
        deleteAction.image = UIImage(systemName: "trash")
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return swipeActions
    }
}
