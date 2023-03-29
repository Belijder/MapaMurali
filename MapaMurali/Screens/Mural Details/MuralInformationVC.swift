//
//  MuralInformationVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 28/03/2023.
//

import UIKit
import MessageUI
import RxSwift

class MuralInformationVC: UIViewController, ReportMuralProtocol {
    
    // MARK: - Properties
    var muralItem: Mural
    let databaseManager: DatabaseManager
    private let presentingVCTitle: String?
    
    private var disposeBag = DisposeBag()
    
    private let addressLabelDescription = MMBodyLabel(textAlignment: .left, text: "Adres")
    private let addressLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    private let authorLabelDescription = MMBodyLabel(textAlignment: .left)
    private let authorLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    private let sendEmailWithAuthorButton = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    private let dateLabelDescription = MMBodyLabel(textAlignment: .left, text: "Data dodania")
    private let dateLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    private let userLabelDescription = MMBodyLabel(textAlignment: .left, text: "Dodano przez")
    private let userView = MMUsernameWithAvatarView(imageHeight: 40)
    
    private let editOrReportMuralButton = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    private let favoriteLabelDescription = MMBodyLabel(textAlignment: .left, text: "Polubienia")
    let favoriteCounter = MMTitleLabel(textAlignment: .left, fontSize: 25)
    
    private let statusLabel = MMTitleLabel(textAlignment: .left, fontSize: 10)
    
    
    // MARK: - Initialization
    init(muralItem: Mural, databaseManager: DatabaseManager, presentingVCTitle: String?) {
        self.muralItem = muralItem
        self.databaseManager = databaseManager
        self.presentingVCTitle = presentingVCTitle
        super.init(nibName: nil, bundle: nil)
        self.favoriteCounter.createFavoriteCounterTextLabel(counter: muralItem.favoritesCount, imagePointSize: 25)
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
        configureViewController()
        checkAuthorPropertyInMuralItem()
        setUpUIElements()
        layoutUI()
        addLastEditedMuralsObserver()
    }
    
    
    // MARK: - Set up
    private func configureViewController() {
        view.backgroundColor = .clear
    }
    
    private func setUpUIElements() {
        authorLabelDescription.text = muralItem.author?.isEmpty == true ? "Znasz autora?" : "Autor"
        authorLabel.text = muralItem.author

        configureAddressLabel()

        dateLabel.text = muralItem.addedDate.convertToDayMonthYearFormat()
        dateLabel.textColor = UIColor.label
        dateLabel.contentMode = .top

        configureUserView()
        
        favoriteCounter.createFavoriteCounterTextLabel(counter: muralItem.favoritesCount, imagePointSize: 25)
        
        configureSendEmailWithAuthorButton()
        configureEditOrReportMuralButton()
        configureStatusLabel()
    }
    
    
    private func layoutUI() {
        view.addSubviews(authorLabelDescription, authorLabel, sendEmailWithAuthorButton, addressLabelDescription, addressLabel, dateLabel, dateLabelDescription, userLabelDescription, userView, favoriteLabelDescription, favoriteCounter, editOrReportMuralButton, statusLabel)
        
        let horizontalPadding: CGFloat = 30
        let verticalPadding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            authorLabelDescription.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            authorLabelDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            authorLabelDescription.heightAnchor.constraint(equalToConstant: 20),
            authorLabelDescription.widthAnchor.constraint(equalToConstant: 150),
            
            authorLabel.topAnchor.constraint(equalTo: authorLabelDescription.bottomAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: authorLabelDescription.leadingAnchor),
            authorLabel.heightAnchor.constraint(equalToConstant: 20),
            authorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            
            sendEmailWithAuthorButton.topAnchor.constraint(equalTo: authorLabelDescription.bottomAnchor),
            sendEmailWithAuthorButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            sendEmailWithAuthorButton.heightAnchor.constraint(equalToConstant: 30),
            sendEmailWithAuthorButton.widthAnchor.constraint(equalToConstant: 150),
            
            addressLabelDescription.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: verticalPadding),
            addressLabelDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            addressLabelDescription.heightAnchor.constraint(equalToConstant: 20),
            addressLabelDescription.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 2),
            
            addressLabel.topAnchor.constraint(equalTo: addressLabelDescription.bottomAnchor),
            addressLabel.leadingAnchor.constraint(equalTo: addressLabelDescription.leadingAnchor),
            addressLabel.heightAnchor.constraint(equalToConstant: 40),
            addressLabel.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 2),
            
            dateLabelDescription.topAnchor.constraint(equalTo: addressLabelDescription.topAnchor),
            dateLabelDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.size.width / 3 * 2),
            dateLabelDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            dateLabelDescription.heightAnchor.constraint(equalToConstant: 20),
            
            dateLabel.topAnchor.constraint(equalTo: addressLabel.topAnchor, constant: 1),
            dateLabel.leadingAnchor.constraint(equalTo: dateLabelDescription.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            dateLabel.heightAnchor.constraint(equalToConstant: 20),
            
            userLabelDescription.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: verticalPadding),
            userLabelDescription.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
            userLabelDescription.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 2),
            userLabelDescription.heightAnchor.constraint(equalToConstant: 20),
            
            userView.topAnchor.constraint(equalTo: userLabelDescription.bottomAnchor, constant: 5),
            userView.leadingAnchor.constraint(equalTo: userLabelDescription.leadingAnchor),
            userView.heightAnchor.constraint(equalToConstant: 40),
            userView.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 2),
            
            favoriteLabelDescription.topAnchor.constraint(equalTo: userLabelDescription.topAnchor),
            favoriteLabelDescription.leadingAnchor.constraint(equalTo: dateLabelDescription.leadingAnchor),
            favoriteLabelDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            favoriteLabelDescription.heightAnchor.constraint(equalToConstant: 20),
            
            favoriteCounter.leadingAnchor.constraint(equalTo: favoriteLabelDescription.leadingAnchor),
            favoriteCounter.topAnchor.constraint(equalTo: favoriteLabelDescription.bottomAnchor),
            favoriteCounter.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            favoriteCounter.heightAnchor.constraint(equalToConstant: 40),
            
            editOrReportMuralButton.leadingAnchor.constraint(equalTo: userLabelDescription.leadingAnchor),
            editOrReportMuralButton.topAnchor.constraint(equalTo: userView.bottomAnchor, constant: verticalPadding + 10),
            editOrReportMuralButton.heightAnchor.constraint(equalToConstant: 20),
            editOrReportMuralButton.widthAnchor.constraint(equalToConstant: 200),
            
            statusLabel.centerYAnchor.constraint(equalTo: editOrReportMuralButton.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusLabel.heightAnchor.constraint(equalToConstant: 15),
            statusLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor)
        ])
    }
    
    
    private func configureAddressLabel() {
        addressLabel.numberOfLines = 2
        addressLabel.adjustsFontSizeToFitWidth = false
        
        if muralItem.address.count < 25 {
            addressLabel.text = "\(muralItem.address),\n\(muralItem.city)"
        } else {
            addressLabel.lineBreakMode = .byWordWrapping
            addressLabel.text = "\(muralItem.address), \(muralItem.city)"
        }
        addressLabel.adjustsFontSizeToFitWidth = false
    }
    
    
    private func configureSendEmailWithAuthorButton() {
        sendEmailWithAuthorButton.text = "Napisz do nas!"
        sendEmailWithAuthorButton.textColor = MMColors.primary
        sendEmailWithAuthorButton.font.withSize(15)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(sendEmailWithAuthor))
        sendEmailWithAuthorButton.isUserInteractionEnabled = true
        sendEmailWithAuthorButton.addGestureRecognizer(tap)
    }
    
    
    private func configureUserView() {
        databaseManager.fetchUserFromDatabase(id: muralItem.addedBy) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.userView.username.text = user.displayName
                    self.userView.avatarView.setImage(from: user.avatarURL, userID: user.id, uiImageSize: CGSize(width: 40, height: 40))
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.userViewTapped))
                    self.userView.isUserInteractionEnabled = true
                    self.userView.addGestureRecognizer(tap)
                    
                case .failure(_):
                    self.userView.username.text = "brak nazwy"
                }
            }
        }
    }
    
    
    private func configureEditOrReportMuralButton() {
        editOrReportMuralButton.isUserInteractionEnabled = true
        editOrReportMuralButton.textColor = .systemYellow
        if muralItem.addedBy == databaseManager.currentUser?.id {
            editOrReportMuralButton.createAttributedString(text: "Edytuj informacje", imageSystemName: "square.and.pencil", imagePointSize: 15, color: .systemYellow)
            let tap = UITapGestureRecognizer(target: self, action: #selector(editMural))
            editOrReportMuralButton.addGestureRecognizer(tap)
        } else {
            editOrReportMuralButton.createAttributedString(text: "Zgłoś mural", imageSystemName: "exclamationmark.bubble", imagePointSize: 15, color: .systemYellow)
            let tap = UITapGestureRecognizer(target: self, action: #selector(reportMural))
            editOrReportMuralButton.addGestureRecognizer(tap)
        }
    }
    
    
    private func configureStatusLabel() {
        if databaseManager.currentUser?.id == muralItem.addedBy {
            switch muralItem.reviewStatus {
            case 0:
                statusLabel.createAttributedString(text: "W poczekalni", imageSystemName: "eye", imagePointSize: 10, color: .systemYellow)
            case 1:
                statusLabel.createAttributedString(text: "Zaakceptowano", imageSystemName: "checkmark", imagePointSize: 10, color: .systemGreen)
            case 2:
                statusLabel.createAttributedString(text: "Zgłoszono", imageSystemName: "exclamationmark.triangle", imagePointSize: 10, color: .systemRed)
            default:
                break
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(showStatusLegend))
            statusLabel.isUserInteractionEnabled = true
            statusLabel.addGestureRecognizer(tap)
        } else {
            statusLabel.alpha = 0.0
        }
    }
    
    
    // MARK: - Actions
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    
    
    final func checkAuthorPropertyInMuralItem() {
        if let author = muralItem.author, author.isEmpty {
            authorLabel.isHidden = true
            sendEmailWithAuthorButton.isHidden = false
        } else {
            sendEmailWithAuthorButton.isHidden = true
            authorLabel.isHidden = false
        }
    }
    
    
    @objc private func sendEmailWithAuthor() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["mapamurali@gmail.com"])
            mail.setSubject("Zgłoszenie autora muralu: \(muralItem.docRef)")
            mail.setMessageBody("<p>Znam autora tego muralu. Autorem jest: </p>", isHTML: true)
            present(mail, animated: true)
        } else {
            presentMMAlert(title: MMMessages.cannotSendMail.title, message: MMMessages.cannotSendMail.message, buttonTitle: "Ok")
        }
    }
    
    
    @objc private func userViewTapped() {
        guard let title = presentingVCTitle,
              let username = userView.username.text,
              title.contains(username)
            else {
                let usersMural = self.databaseManager.murals.filter { $0.addedBy == muralItem.addedBy }
                
                let destVC = MuralsCollectionViewController(databaseManager: self.databaseManager)
                destVC.title = "Dodane przez \(userView.username.text ?? "użytkownika")"
                destVC.murals = usersMural
                
                let navControler = UINavigationController(rootViewController: destVC)
                navControler.modalPresentationStyle = .fullScreen
                navControler.navigationBar.tintColor = MMColors.primary
                present(navControler, animated: true)
                return
            }
        self.dismissVC()
    }
    
    
    @objc private func showStatusLegend() {
        let destVC = ReviewStatusLegendVC()
        destVC.modalPresentationStyle = .formSheet
        self.present(destVC, animated: true)
    }
    
    
    @objc private func editMural() {
        let destVC = EditMuralViewController(mural: muralItem, databaseManager: self.databaseManager)
        let navControler = UINavigationController(rootViewController: destVC)
        navControler.modalPresentationStyle = .fullScreen
        self.present(navControler, animated: true)
    }
    
    
    @objc private func reportMural() {
        presentReportMuralActionSheet()
    }

    
    // MARK: - Binding
    private func addLastEditedMuralsObserver() {
        databaseManager.lastEditedMuralID
            .subscribe(onNext: { editedMural in
                if editedMural.docRef == self.muralItem.docRef {
                    self.muralItem.address = editedMural.address
                    self.muralItem.city = editedMural.city
                    self.addressLabel.text = "\(editedMural.address), \(editedMural.city)"
                    self.muralItem.author = editedMural.author
                    self.authorLabel.text = editedMural.author
                    self.checkAuthorPropertyInMuralItem()
                }
            })
            .disposed(by: disposeBag)
    }
}


//MARK: - Extensions
extension MuralInformationVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
