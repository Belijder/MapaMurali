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
    var muralItem: Mural!
    var databaseManager: DatabaseManager!
    var vm: MuralDetailsViewModel
    var disposeBag = DisposeBag()
    
    var imageView = MMFullSizeImageView(frame: .zero)
    var containerView = UIView()
    
    var closeButton = MMCircleButton(color: .white, systemImageName: "xmark")
    var favoriteButton = MMCircleButton(color: MMColors.primary)
    var mapPinButton = MMCircleButton(color: .white, systemImageName: "mappin.and.ellipse")
    
   
    var authorLabelDescription = MMBodyLabel(textAlignment: .left)
    var authorLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    var sendEmailWithAuthorButton = MMTitleLabel(textAlignment: .left, fontSize: 15)
    var dateLabelDescription = MMBodyLabel(textAlignment: .left)
    var dateLabel = MMBodyLabel(textAlignment: .left)
    var userLabelDescription = MMBodyLabel(textAlignment: .left)
    var userView = MMUsernameWithAvatarView(imageHeight: 40)
    
    var editOrReportMuralButton = MMCircleButton()
    var deleteMuralButton = MMCircleButton(color: .systemRed, systemImageName: "trash")
    
    let favoriteCounter = MMTitleLabel(textAlignment: .center, fontSize: 25)
    
    
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
        containerView.addSubviews(mapPinButton, dateLabelDescription, dateLabel, authorLabelDescription, authorLabel, sendEmailWithAuthorButton, userLabelDescription, userView, favoriteCounter, editOrReportMuralButton)
        view.addSubviews(imageView, containerView, favoriteButton, closeButton, deleteMuralButton)
        
        configureViewController()
        checkAuthorPropertyInMuralItem()
        configureContainerView()
        configureUIElements()
        layoutUI()
        addFavoriteObserver()
        addLastEditedMuralsObserver()
    }
    
    //MARK: - Logic
    func checkAuthorPropertyInMuralItem() {
        if let author = muralItem.author, author.isEmpty {
            authorLabel.isHidden = true
            sendEmailWithAuthorButton.isHidden = false
        } else {
            sendEmailWithAuthorButton.isHidden = true
            authorLabel.isHidden = false
        }
    }
    
    
    
    //MARK: - Set up
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.tintColor = MMColors.primary
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    
    func configureContainerView() {
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.systemBackground.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: -4)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.2
        containerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func configureSendEmailWithAuthorButton() {
        sendEmailWithAuthorButton.text = "Napisz do nas!"
        sendEmailWithAuthorButton.textColor = MMColors.primary
        sendEmailWithAuthorButton.font.withSize(15)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(sendEmailWithAuthor))
        sendEmailWithAuthorButton.isUserInteractionEnabled = true
        sendEmailWithAuthorButton.addGestureRecognizer(tap)
    }
    
    
    func configureUIElements() {
        if imageView.image == nil {
            imageView.downloadImage(from: muralItem.imageURL, imageType: .fullSize, docRef: muralItem.docRef)
        }
        
        mapPinButton.configuration?.baseBackgroundColor = MMColors.primary
        mapPinButton.addTarget(self, action: #selector(mapPinButtonTapped), for: .touchUpInside)
        
        authorLabelDescription.text = muralItem.author?.isEmpty == true ? "Znasz autora?" : "Autor"
        authorLabel.text = muralItem.author
        
        dateLabelDescription.text = "Data dodania:"
        dateLabel.text = muralItem.addedDate.convertToDayMonthYearFormat()
        dateLabel.textColor = .white
        
        userLabelDescription.text = "Dodano przez:"
        
        configureUserView()
        
        favoriteButton.set(systemImageName: vm.favoriteImageName)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        configureCloseButton()
        
        favoriteCounter.createFavoriteCounterTextLabel(counter: muralItem.favoritesCount, imagePointSize: 25)
        
        configureSendEmailWithAuthorButton()
        
        configureEditOrReportMuralButton()
        configureDeleteButton()
    }
    
    
    func configureEditOrReportMuralButton() {
        editOrReportMuralButton.set(color: .systemYellow)
        editOrReportMuralButton.configuration?.baseBackgroundColor = .systemYellow.withAlphaComponent(0.3)
        if muralItem.addedBy == databaseManager.currentUser?.id {
            editOrReportMuralButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
            editOrReportMuralButton.addTarget(self, action: #selector(editMural), for: .touchUpInside)
        } else {
            editOrReportMuralButton.setImage(UIImage(systemName: "exclamationmark.bubble"), for: .normal)
            editOrReportMuralButton.addTarget(self, action: #selector(reportMural), for: .touchUpInside)
        }
    }
    
    
    func configureDeleteButton() {
        if muralItem.addedBy == databaseManager.currentUser?.id {
            deleteMuralButton.addTarget(self, action: #selector(deleteMuralButtonTapped), for: .touchUpInside)
        } else {
            deleteMuralButton.alpha = 0.0
        }
    }
    
    func configureCloseButton() {
        closeButton.configuration?.baseBackgroundColor = .clear
        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
    }
    
    func configureUserView() {
        databaseManager.fetchUserFromDatabase(id: muralItem.addedBy) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.userView.username.text = user.displayName
                    self.userView.avatarView.setImage(from: user.avatarURL, userID: user.id)
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.userViewTapped))
                    self.userView.isUserInteractionEnabled = true
                    self.userView.addGestureRecognizer(tap)
                    
                case .failure(let error):
                    print("🔴 Error to fetch users info from Database. Error: \(error)")
                    self.userView.username.text = "brak nazwy"
                }
            }
        }
    }
    
    
    func layoutUI() {
        let horizontalPadding: CGFloat = 30
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            imageView.heightAnchor.constraint(equalToConstant: view.bounds.width / 3 * 4),
            
            favoriteButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 20),
            favoriteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -20),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            
            closeButton.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -20),
            
            mapPinButton.centerYAnchor.constraint(equalTo: containerView.topAnchor),
            mapPinButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -50),
            mapPinButton.heightAnchor.constraint(equalToConstant: 64),
            mapPinButton.widthAnchor.constraint(equalToConstant: 64),
            
            dateLabelDescription.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            dateLabelDescription.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            dateLabelDescription.heightAnchor.constraint(equalToConstant: 20),
            dateLabelDescription.widthAnchor.constraint(equalToConstant: 100),
            
            dateLabel.centerYAnchor.constraint(equalTo: dateLabelDescription.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateLabelDescription.trailingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: mapPinButton.leadingAnchor, constant: -10),
            dateLabel.heightAnchor.constraint(equalToConstant: 20),
            
            authorLabelDescription.topAnchor.constraint(equalTo: mapPinButton.bottomAnchor, constant: 20),
            authorLabelDescription.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalPadding),
            authorLabelDescription.heightAnchor.constraint(equalToConstant: 20),
            authorLabelDescription.widthAnchor.constraint(equalToConstant: 150),
            
            authorLabel.topAnchor.constraint(equalTo: authorLabelDescription.bottomAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: authorLabelDescription.leadingAnchor),
            authorLabel.heightAnchor.constraint(equalToConstant: 30),
            authorLabel.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 3 * 2),
            
            sendEmailWithAuthorButton.topAnchor.constraint(equalTo: authorLabelDescription.bottomAnchor),
            sendEmailWithAuthorButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalPadding),
            sendEmailWithAuthorButton.heightAnchor.constraint(equalToConstant: 30),
            sendEmailWithAuthorButton.widthAnchor.constraint(equalToConstant: 150),
            
            userLabelDescription.topAnchor.constraint(equalTo: sendEmailWithAuthorButton.bottomAnchor, constant: 15),
            userLabelDescription.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalPadding),
            userLabelDescription.heightAnchor.constraint(equalToConstant: 30),
            userLabelDescription.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 3 * 2),
            
            userView.topAnchor.constraint(equalTo: userLabelDescription.bottomAnchor),
            userView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalPadding),
            userView.heightAnchor.constraint(equalToConstant: 40),
            userView.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 3 * 2),
            
            favoriteCounter.centerYAnchor.constraint(equalTo: authorLabel.centerYAnchor),
            favoriteCounter.centerXAnchor.constraint(equalTo: mapPinButton.centerXAnchor),
            favoriteCounter.widthAnchor.constraint(equalToConstant: 50),
            favoriteCounter.heightAnchor.constraint(equalToConstant: 50),
            
            editOrReportMuralButton.centerYAnchor.constraint(equalTo: userView.centerYAnchor),
            editOrReportMuralButton.centerXAnchor.constraint(equalTo: mapPinButton.centerXAnchor),
            editOrReportMuralButton.heightAnchor.constraint(equalToConstant: 44),
            editOrReportMuralButton.widthAnchor.constraint(equalToConstant: 44),
            
            deleteMuralButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -40),
            deleteMuralButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 20),
            deleteMuralButton.heightAnchor.constraint(equalToConstant: 44),
            deleteMuralButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    //MARK: - Logic
    
    func deleteMural() {
        self.databaseManager.removeMural(for: muralItem.docRef) { success in
            if success == true {
                print("🟢 Mural was succesfully deleted from database.")
                self.databaseManager.lastDeletedMuralID.onNext(self.muralItem.docRef)
            } else {
                print("🔴 Try to delete mural from database faild.")
            }
        }
        self.databaseManager.murals.removeAll(where: { $0.docRef == muralItem.docRef })
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Actions
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    
    
    @objc func favoriteButtonTapped() {
        vm.favoriteButtonTapped()
    }
    
    @objc func mapPinButtonTapped() {
        print("🟡 Map Pin button tapped.")
        databaseManager.mapPinButtonTappedOnMural.onNext(muralItem)
        dismissVC()
    }
    
    @objc func userViewTapped() {
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
    
    
    @objc func sendEmailWithAuthor() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["mapamurali@gmail.com"])
            mail.setMessageBody("<p>Znam autora tego muralu -> (ID: \(muralItem.docRef)). /n /n Autorem jest: </p>", isHTML: true)
            present(mail, animated: true)
        } else {
            presentMMAlert(title: "Nie można wysłać maila", message: "Sprawdź czy masz skonfugurowanego klienta pocztowego i spróbuj ponownie. ", buttonTitle: "Ok")
        }
    }
    
    
    @objc func editMural() {
        print("🟡 Edit Mural Button Tapped")
        let destVC = EditMuralViewController(mural: muralItem, databaseManager: self.databaseManager)
        let navControler = UINavigationController(rootViewController: destVC)
        navControler.modalPresentationStyle = .fullScreen
        self.present(navControler, animated: true)
    }
    
    
    @objc func reportMural() {
        print("🟡 Report Mural Button Tapped")
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
    
    @objc func deleteMuralButtonTapped() {
        let actionSheet = UIAlertController(title: "Usunąć mural?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Usuń", style: .destructive) { _ in self.deleteMural() })
        actionSheet.addAction(UIAlertAction(title: "Anuluj", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    //MARK: - Binding
    func addFavoriteObserver() {
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
    
    func addLastEditedMuralsObserver() {
        databaseManager.lastEditedMuralID
            .subscribe(onNext: { editedMural in
                if editedMural.docRef == self.muralItem.docRef {
                    self.muralItem.adress = editedMural.adress
                    self.muralItem.city = editedMural.city
                    self.title = editedMural.adress
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
