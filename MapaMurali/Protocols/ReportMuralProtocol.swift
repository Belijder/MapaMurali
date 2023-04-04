//
//  ReportMuralProtocol.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 28/03/2023.
//

import UIKit

protocol ReportMuralProtocol: UIViewController {
    var databaseManager: DatabaseManager { get }
    var muralItem: Mural { get }
    func dismissVC() -> Void
    
}

extension ReportMuralProtocol {
    func presentReportMuralActionSheet() {
        let actionSheet = UIAlertController(title: "Co chcesz zgłosić?", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: ReportType.controversialContent.rawValue, style: .destructive) { _ in
            self.createMuralReport(reportType: .controversialContent) })
        
        actionSheet.addAction(UIAlertAction(title: ReportType.wrongAddress.rawValue, style: .default) { _ in
            self.createMuralReport(reportType: .wrongAddress)})
        
        actionSheet.addAction(UIAlertAction(title: ReportType.wrongAuthor.rawValue, style: .default) { _ in
            self.createMuralReport(reportType: .wrongAuthor)})
        
        actionSheet.addAction(UIAlertAction(title: ReportType.muralNoLongerExist.rawValue, style: .default) { _ in
            self.createMuralReport(reportType: .muralNoLongerExist)})
        
        actionSheet.addAction(UIAlertAction(title: ReportType.otherReport.rawValue, style: .default) { _ in
            self.createMuralReport(reportType: ReportType.otherReport)})
        
        actionSheet.addAction(UIAlertAction(title: "Zablokuj użytkownika", style: .destructive) { _ in
            self.databaseManager.blockUserContent(userID: self.muralItem.addedBy) { success in
                if success {
                    self.presentMMAlert(message: MMMessages.userHasBeenBlocked) {
                        self.view.window?.rootViewController?.dismiss(animated: false)
                    }
                }
            }
        })
        
        actionSheet.addAction(UIAlertAction(title: "Anuluj", style: .cancel))
        present(actionSheet, animated: true)
        
    }
    
    
    private func createMuralReport(reportType: ReportType) {
        guard NetworkMonitor.shared.isConnected == true else {
            presentMMAlert(title: "Brak połączenia", message: MMError.noConnectionDefaultMessage.rawValue)
            return
        }
        
        guard let userID = databaseManager.currentUser?.id else {
            presentMMAlert(message: MMMessages.unableToSentReport)
            return
        }
        
        databaseManager.addNewReport(muralID: muralItem.docRef, userID: userID, reportType: reportType) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let reportID):
                switch reportType {
                case .controversialContent:
                    self.databaseManager.changeMuralReviewStatus(muralID: self.muralItem.docRef, newStatus: 2) { result in
                        switch result {
                        case .success(_):
                            self.databaseManager.lastReportedMuralID.onNext(self.muralItem.docRef)
                            self.showAddMoreDetailsForReport(reportType: .controversialContent, title: MMMessages.reportAccepted.title, message: MMMessages.reportAccepted.message, reportID: reportID)
                        case .failure(_):
                            self.presentMMAlert(message: MMMessages.unableToSentReport)
                        }
                    }
                case .wrongAddress:
                    self.showAddMoreDetailsForReport(reportType: .wrongAddress, title: "Dzięki za informacje!", message: "Jaki powinien być prawidłowy adres?", reportID: reportID)
                case .wrongAuthor:
                    self.showAddMoreDetailsForReport(reportType: .wrongAddress, title: "Dzięki za informacje!", message: "Kto powinien być podany jako autor?", reportID: reportID)
                case .muralNoLongerExist:
                    self.showAddMoreDetailsForReport(reportType: .muralNoLongerExist, title: "Dzięki za informacje!", message: "Czy chcesz podać więcej szczegółów?", reportID: reportID)
                case .otherReport:
                    self.showAddMoreDetailsForReport(reportType: .otherReport, title: "W czym problem?", message: "Napisz nam co chciałbyś zgłosić.", reportID: reportID)
                }
                
            case .failure(_):
                self.presentMMAlert(message: MMMessages.unableToSentReport)
            }
        }
    }
    
    
    private func showAddMoreDetailsForReport(reportType: ReportType, title: String, message: String, reportID: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = "Wpisz tutaj..."
            field.autocapitalizationType = .sentences
            field.autocorrectionType = .yes
            field.clearButtonMode = .unlessEditing
            field.returnKeyType = .continue
            field.textContentType = .oneTimeCode
        }
        
        alert.addAction(UIAlertAction(title: "Anuluj", style: .cancel) { _ in
            let message = "Brak"
            self.databaseManager.addAdditionalMessageFor(reportID: reportID, message: message)
            if reportType == .controversialContent {
                self.dismissVC()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Wyślij", style: .default) { _ in
            let message = alert.textFields![0].text ?? "Brak"
            self.databaseManager.addAdditionalMessageFor(reportID: reportID, message: message)
            if reportType == .controversialContent {
                self.dismissVC()
            }
        })
        
        present(alert, animated: true)
    }
}


enum ReportType: String {
    case controversialContent = "Niestosowne treści"
    case wrongAddress = "Błędny adres muralu"
    case wrongAuthor = "Niewłaściwy autor"
    case muralNoLongerExist = "Mural już nie istnieje"
    case otherReport = "Inne zgłoszenie"
}
