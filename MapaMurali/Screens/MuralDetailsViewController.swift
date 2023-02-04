//
//  MuralDetailsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 08/10/2022.
//

import UIKit
import RxSwift
import MessageUI

class MuralDetailsViewController: UIViewController {
    
    //MARK: - Properties
    private var muralItem: Mural!
    private var databaseManager: DatabaseManager!
    private let vm: MuralDetailsViewModel
    private var disposeBag = DisposeBag()
    
    let imageView = MMFullSizeImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 3 * 4))
    let containerView = UIView()
    
    let closeButton = MMCircleButton(color: .white, systemImageName: "xmark")
    let favoriteButton = MMCircleButton(color: MMColors.primary)
    let mapPinButton = MMCircleButton(color: .white, systemImageName: "mappin.and.ellipse")
    
    private let addressLabelDescription = MMBodyLabel(textAlignment: .left)
    private let addressLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    private let authorLabelDescription = MMBodyLabel(textAlignment: .left)
    private let authorLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    private let sendEmailWithAuthorButton = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    private let dateLabelDescription = MMBodyLabel(textAlignment: .left)
    private let dateLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    
    private let userLabelDescription = MMBodyLabel(textAlignment: .left)
    private let userView = MMUsernameWithAvatarView(imageHeight: 40)
    
    private let editOrReportMuralButton = MMTitleLabel(textAlignment: .left, fontSize: 15)
    let deleteMuralButton = MMCircleButton(color: .systemRed, systemImageName: "trash")
    
    private let favoriteLabelDescription = MMBodyLabel(textAlignment: .left)
    private let favoriteCounter = MMTitleLabel(textAlignment: .left, fontSize: 25)
    
    
    //MARK: - Initialization
    init(muralItem: Mural, databaseManager: DatabaseManager, presentingVCTitle: String?) {
        self.vm = MuralDetailsViewModel(databaseManager: databaseManager, muralID: muralItem.docRef, counterValue: muralItem.favoritesCount, presentingVCTitle: presentingVCTitle)
        super.init(nibName: nil, bundle: nil)
        self.muralItem = muralItem
        self.databaseManager = databaseManager
        self.favoriteCounter.createFavoriteCounterTextLabel(counter: muralItem.favoritesCount, imagePointSize: 25)
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
        configureViewController()
        checkAuthorPropertyInMuralItem()
        configureContainerView()
        configureUIElements()
        layoutUI()
        addFavoriteObserver()
        addLastEditedMuralsObserver()
    }
    
    
    //MARK: - Set up
    private func configureViewController() {
        view.backgroundColor = .systemBackground
    }
    
    
    private func configureContainerView() {
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.systemBackground.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: -4)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.2
        containerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    private func configureSendEmailWithAuthorButton() {
        sendEmailWithAuthorButton.text = "Napisz do nas!"
        sendEmailWithAuthorButton.textColor = MMColors.primary
        sendEmailWithAuthorButton.font.withSize(15)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(sendEmailWithAuthor))
        sendEmailWithAuthorButton.isUserInteractionEnabled = true
        sendEmailWithAuthorButton.addGestureRecognizer(tap)
    }
    
    
    private func configureUIElements() {
        if imageView.image == nil {
            imageView.downloadImage(from: muralItem.imageURL, imageType: .fullSize, docRef: muralItem.docRef)
        }
        
        imageView.contentMode = .scaleAspectFill
        
        mapPinButton.configuration?.baseBackgroundColor = MMColors.primary
        mapPinButton.addTarget(self, action: #selector(mapPinButtonTapped), for: .touchUpInside)
        
        authorLabelDescription.text = muralItem.author?.isEmpty == true ? "Znasz autora?" : "Autor"
        authorLabel.text = muralItem.author
        
        addressLabelDescription.text = "Adres"
        configureAddressLabel()
        
        dateLabelDescription.text = "Data dodania"
        dateLabel.text = muralItem.addedDate.convertToDayMonthYearFormat()
        dateLabel.textColor = .white
        dateLabel.contentMode = .top
        
        userLabelDescription.text = "Dodano przez"
        
        configureUserView()
        
        favoriteLabelDescription.text = "Polubienia"
        favoriteButton.set(systemImageName: vm.favoriteImageName)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        configureCloseButton()
        
        favoriteCounter.createFavoriteCounterTextLabel(counter: muralItem.favoritesCount, imagePointSize: 25)
        
        configureSendEmailWithAuthorButton()
        
        configureEditOrReportMuralButton()
        configureDeleteButton()
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
    
    
    private func configureDeleteButton() {
        if muralItem.addedBy == databaseManager.currentUser?.id {
            deleteMuralButton.addTarget(self, action: #selector(deleteMuralButtonTapped), for: .touchUpInside)
        } else {
            deleteMuralButton.alpha = 0.0
        }
    }
    
    
    private func configureCloseButton() {
        closeButton.configuration?.baseBackgroundColor = .clear
        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
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
    
    
    private func layoutUI() {
        containerView.addSubviews(mapPinButton, dateLabelDescription, dateLabel, authorLabelDescription, authorLabel, addressLabelDescription, addressLabel, sendEmailWithAuthorButton, userLabelDescription, userView, favoriteLabelDescription, favoriteCounter, editOrReportMuralButton)
        view.addSubviews(imageView, containerView, favoriteButton, closeButton, deleteMuralButton)
        
        let horizontalPadding: CGFloat = 30
        let verticalPadding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            imageView.heightAnchor.constraint(equalToConstant: view.bounds.width / 3 * 4),
            
            favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -20),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            
            closeButton.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            
            deleteMuralButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -40),
            deleteMuralButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 20),
            deleteMuralButton.heightAnchor.constraint(equalToConstant: 44),
            deleteMuralButton.widthAnchor.constraint(equalToConstant: 44),
            
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -20),
            
            mapPinButton.centerYAnchor.constraint(equalTo: containerView.topAnchor),
            mapPinButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -50),
            mapPinButton.heightAnchor.constraint(equalToConstant: 64),
            mapPinButton.widthAnchor.constraint(equalToConstant: 64),
            
            authorLabelDescription.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            authorLabelDescription.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalPadding),
            authorLabelDescription.heightAnchor.constraint(equalToConstant: 20),
            authorLabelDescription.widthAnchor.constraint(equalToConstant: 150),
            
            authorLabel.topAnchor.constraint(equalTo: authorLabelDescription.bottomAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: authorLabelDescription.leadingAnchor),
            authorLabel.heightAnchor.constraint(equalToConstant: 20),
            authorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            
            sendEmailWithAuthorButton.topAnchor.constraint(equalTo: authorLabelDescription.bottomAnchor),
            sendEmailWithAuthorButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalPadding),
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
            editOrReportMuralButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    
    //MARK: - Logic
    private func checkAuthorPropertyInMuralItem() {
        if let author = muralItem.author, author.isEmpty {
            authorLabel.isHidden = true
            sendEmailWithAuthorButton.isHidden = false
        } else {
            sendEmailWithAuthorButton.isHidden = true
            authorLabel.isHidden = false
        }
    }
    
    
    private func deleteMural() {
        self.databaseManager.removeMural(for: muralItem.docRef) { success in
            if success == true {
                self.databaseManager.lastDeletedMuralID.onNext(self.muralItem.docRef)
            }
        }
        self.databaseManager.murals.removeAll(where: { $0.docRef == muralItem.docRef })
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Actions
    @objc private func dismissVC() {
        self.dismiss(animated: true)
    }
    
    
    @objc private func favoriteButtonTapped() {
        vm.favoriteButtonTapped()
    }
    
    
    @objc private func mapPinButtonTapped() {
        databaseManager.mapPinButtonTappedOnMural.onNext(muralItem)
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    
    @objc private func userViewTapped() {
        guard let title = vm.presentingVCTitle,
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
    
    
    @objc private func sendEmailWithAuthor() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["mapamurali@gmail.com"])
            mail.setSubject("Zgłoszenie autora muralu: \(muralItem.docRef)")
            mail.setMessageBody("<p>Znam autora tego muralu. Autorem jest: </p>", isHTML: true)
            present(mail, animated: true)
        } else {
            presentMMAlert(title: "Nie można wysłać maila", message: "Sprawdź czy masz skonfugurowanego klienta pocztowego i spróbuj ponownie. ", buttonTitle: "Ok")
        }
    }
    
    
    @objc private func editMural() {
        let destVC = EditMuralViewController(mural: muralItem, databaseManager: self.databaseManager)
        let navControler = UINavigationController(rootViewController: destVC)
        navControler.modalPresentationStyle = .fullScreen
        self.present(navControler, animated: true)
    }
    
    
    @objc private func reportMural() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["mapamurali@gmail.com"])
            mail.setSubject("Zgłoszenie dotyczące muralu: \(muralItem.docRef)")
            mail.setMessageBody("<p>Napisz czego dotyczy zgłoszenie</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            presentMMAlert(title: "Nie można wysłać maila", message: "Sprawdź czy masz skonfugurowanego klienta pocztowego i spróbuj ponownie. ", buttonTitle: "Ok")
        }
    }
    
    
    @objc private func deleteMuralButtonTapped() {
        let actionSheet = UIAlertController(title: "Usunąć mural?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Usuń", style: .destructive) { _ in self.deleteMural() })
        actionSheet.addAction(UIAlertAction(title: "Anuluj", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    
    //MARK: - Binding
    private func addFavoriteObserver() {
        vm.isUserFavorite
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                
                switch value {
                case true:
                    self.favoriteButton.set(systemImageName: "heart.fill")
                case false:
                    self.favoriteButton.set(systemImageName: "heart")
                }
                self.favoriteCounter.createFavoriteCounterTextLabel(counter: self.vm.counterValue, imagePointSize: 25)
            })
            .disposed(by: disposeBag)
    }
    
    
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
extension MuralDetailsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
