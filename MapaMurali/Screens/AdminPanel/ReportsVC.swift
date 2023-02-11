//
//  ReportsVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 10/02/2023.
//

import UIKit
import RxSwift

class ReportsVC: MMDataLoadingVC {

    // MARK: - Properties
    private var reportsTableView: UITableView!
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
        configureMuralTableView()
        bindReportTableView()
        addDatabaseReportsObserver()
    }
    
    
    // MARK: - Set up
    private func configureMuralTableView() {
        reportsTableView = UITableView(frame: view.bounds)
        view.addSubview(reportsTableView)
        reportsTableView.delegate = self
        reportsTableView.backgroundColor = .systemBackground
        reportsTableView.register(MMReportCell.self, forCellReuseIdentifier: MMReportCell.identifier)
    }

    
    //MARK: - Biding
    private func bindReportTableView() {
        databaseManager.reportsPublisher
            .bind(to: reportsTableView.rx.items(cellIdentifier: MMReportCell.identifier, cellType: MMReportCell.self)) { (row, report, cell) in
                let mural = self.databaseManager.murals.first(where: { $0.docRef == report.muralID })
                cell.set(from: report, thumbnailURL: mural?.thumbnailURL ?? "")
                cell.muralImageView.layer.cornerRadius = 10
            }
            .disposed(by: disposeBag)
        
        reportsTableView.rx.modelSelected(Report.self)
            .subscribe(onNext: { [weak self] report in
                guard let self = self else { return }
                guard let mural = self.databaseManager.murals.first(where: { $0.docRef == report.muralID }) else { return }
                let destVC = MuralDetailsViewController(muralItem: mural, databaseManager: self.databaseManager, presentingVCTitle: self.title)
                destVC.modalPresentationStyle = .fullScreen
                self.present(destVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
    private func addDatabaseReportsObserver() {
        databaseManager.reportsPublisher
            .subscribe(onNext: { [weak self] reports in
                guard let self = self else { return }
                
                if reports.isEmpty {
                    self.showEmptyStateView(with: "Nie ma żadnych zgłoszeń do wyświetlenia.", in: self.view)
                }
            })
            .disposed(by: disposeBag)
    }
}


//MARK: - Extensions
extension ReportsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if databaseManager.reports[indexPath.row].reportType == "Niestosowne treści" {
            let muralID = databaseManager.reports[indexPath.row].muralID
            
            let confirmAction = UIContextualAction(style: .normal, title: "Potwierdż") { _, _, completed in
                print("🟢 Mural potwierdzono jako niestosowny.")
                let userID = self.databaseManager.reports[indexPath.row].userID
                
                self.databaseManager.removeMural(for: muralID) { _ in
                    self.databaseManager.removeReport(for: self.databaseManager.reports[indexPath.row].reportID) { _ in
                        self.databaseManager.changeNumberOfMuralsAddedBy(user: userID, by: -1)
                        self.databaseManager.reports.remove(at: indexPath.row)
                    }
                }

                completed(true)
            }
            
            let rejectAction = UIContextualAction(style: .normal, title: "Odrzuć") { _, _, completed in
                print("🔴 Odrzucono zgłoszenie.")
                self.databaseManager.changeMuralReviewStatus(muralID: muralID, newStatus: 1) { _ in }
                
                self.databaseManager.removeReport(for: self.databaseManager.reports[indexPath.row].reportID) { _ in
                    self.databaseManager.reports.remove(at: indexPath.row)
                }
                
                completed(true)
            }
            
            confirmAction.backgroundColor = .systemGreen
            confirmAction.image = UIImage(systemName: "checkmark")
            rejectAction.backgroundColor = .systemRed
            rejectAction.image = UIImage(systemName: "xmark")
            
            let swipeActions = UISwipeActionsConfiguration(actions: [confirmAction, rejectAction])
            return swipeActions
        } else {
            
            let reportID = self.databaseManager.reports[indexPath.row].reportID
            let deleteReport = UIContextualAction(style: .normal, title: "Usuń") { _, _, completed in
                print("🟢 Usunięto zgłoszenie")
                
                self.databaseManager.removeReport(for: reportID) { _ in
                    self.databaseManager.reports.remove(at: indexPath.row)
                }
                
                completed(true)
            }
            
            deleteReport.image = UIImage(systemName: "trash")
            
            let swipeActions = UISwipeActionsConfiguration(actions: [deleteReport])
            return swipeActions
        }
    }
}
