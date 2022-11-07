//
//  MuralDetailsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 08/10/2022.
//

import UIKit
import SwiftUI
import RxSwift

class MuralDetailsViewController: UIViewController {
    
    var muralItem: Mural!
    var imageView = MMFullSizeImageView(frame: .zero)
    var databaseManager: DatabaseManager!
    var vm: MuralDetailsViewModel
    var bag = DisposeBag()
    
    var favoriteButton = MMCircleButton(color: .systemRed)
    var mapPinButton = MMCircleButton(color: .white, systemImageName: "mappin.and.ellipse")
    var containerView = UIView()
    var authorLabelDescription = MMBodyLabel(textAlignment: .left)
    var authorLabel = MMTitleLabel(textAlignment: .left, fontSize: 15)
    var sendEmailWithAuthorButton = MMTitleLabel(textAlignment: .left, fontSize: 15)
    var dateLabelDescription = MMBodyLabel(textAlignment: .left)
    var dateLabel = MMBodyLabel(textAlignment: .left)
    var userLabelDescription = MMBodyLabel(textAlignment: .left)
    
    let favoriteCounter = MMTitleLabel(textAlignment: .center, fontSize: 25)
    
    var userView = MMUsernameWithAvatarView(imageHeight: 40)
    
    init(muralItem: Mural, databaseManager: DatabaseManager) {
        self.vm = MuralDetailsViewModel(databaseManager: databaseManager, muralID: muralItem.docRef, counterValue: muralItem.favoritesCount)
        super.init(nibName: nil, bundle: nil)
        self.muralItem = muralItem
        self.databaseManager = databaseManager
        self.favoriteCounter.createFavoriteCounterTextLabel(counter: muralItem.favoritesCount, imagePointSize: 25)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.addSubviews(mapPinButton, dateLabelDescription, dateLabel, authorLabelDescription, authorLabel, sendEmailWithAuthorButton, userLabelDescription, userView, favoriteCounter)
        view.addSubviews(imageView, containerView, favoriteButton)
        
        
        configureViewController()
        checkAuthorPropertyInMuralItem()
        configureContainerView()
        configureUIElements()
        layoutUI()
        addFavoriteObserver()
    }
    
    func checkAuthorPropertyInMuralItem() {
        if let author = muralItem.author, author.isEmpty {
            authorLabel.isHidden = true
        } else {
            sendEmailWithAuthorButton.isHidden = true
        }
    }
    
    func addFavoriteObserver() {
        vm.isUserFavorite
            .subscribe(onNext: { value in
                switch value {
                case true:
                    self.favoriteButton.set(systemImageName: "heart.fill")
                case false:
                    self.favoriteButton.set(systemImageName: "heart")
                }
                self.favoriteCounter.createFavoriteCounterTextLabel(counter: self.vm.counterValue, imagePointSize: 25)
            })
            .disposed(by: bag)
    }
    
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.tintColor = MMColors.primary
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    func configureContainerView() {
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 30
        containerView.layer.shadowColor = UIColor.systemBackground.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: -4)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.2
        containerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureSendEmailWithAuthorButton() {
        
    }
    
    func configureUIElements() {
        imageView.downloadImage(from: muralItem.imageURL)
        
        mapPinButton.configuration?.baseBackgroundColor = MMColors.primary
        
        
        authorLabelDescription.text = muralItem.author?.isEmpty == true ? "Znasz autora?" : "Autor"
        authorLabel.text = muralItem.author
        
        sendEmailWithAuthorButton.text = "Napisz do nas!"
        sendEmailWithAuthorButton.textColor = .systemBlue
        sendEmailWithAuthorButton.font.withSize(15)
        
        dateLabelDescription.text = "Data dodania:"
        dateLabel.text = muralItem.addedDate.convertToDayMonthYearFormat()
        dateLabel.textColor = .white
        
        userLabelDescription.text = "Dodano przez:"
        
        configureUserView()
        
        favoriteButton.set(systemImageName: vm.favoriteImageName)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        favoriteCounter.createFavoriteCounterTextLabel(counter: muralItem.favoritesCount, imagePointSize: 25)
    }
    
    func configureUserView() {
        databaseManager.fetchUserFromDatabase(id: muralItem.addedBy) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.userView.username.text = user.displayName
                    self.userView.avatarView.setImage(from: user.avatarURL)
                case .failure(let error):
                    print("🔴 Error to fetch users info from Database. Error: \(error)")
                    self.userView.username.text = "brak nazwy"
                }
            }
        }
    }
    
    
    func layoutUI() {
        
        let horizontalPadding: CGFloat = 20
        //let verticalPadding: CGFloat = 10
        
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            imageView.heightAnchor.constraint(equalToConstant: view.bounds.width / 3 * 4),
            
            favoriteButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 20),
            favoriteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -20),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            
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
            
            favoriteCounter.centerYAnchor.constraint(equalTo: userView.centerYAnchor),
            favoriteCounter.centerXAnchor.constraint(equalTo: mapPinButton.centerXAnchor),
            favoriteCounter.widthAnchor.constraint(equalToConstant: 50),
            favoriteCounter.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    
    @objc func favoriteButtonTapped() {
        vm.favoriteButtonTapped()
        
    }
}
