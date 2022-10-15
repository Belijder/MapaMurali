//
//  MuralDetailsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 08/10/2022.
//

import UIKit
import SwiftUI

class MuralDetailsViewController: UIViewController {
    
    var muralItem: Mural!
    var imageView = MMFullSizeImageView(frame: .zero)
    
    //var favoriteButton: UIButton!
    
    var mapPinButton = MMCircleButton(color: .white, systemImageName: "mappin.and.ellipse")
    var containerView = UIView()
    var authorLabelDescription = MMBodyLabel(textAlignment: .left)
    var authorLabel = MMTitleLabel(textAlignment: .left, fontSize: 20)
    var sendEmailWithAuthorButton = MMTitleLabel(textAlignment: .left, fontSize: 20)
    var dateLabelDescription = MMBodyLabel(textAlignment: .left)
    var dateLabel = MMBodyLabel(textAlignment: .left)
    var userLabelDescription = MMBodyLabel(textAlignment: .left)
    var userLabel = MMTitleLabel(textAlignment: .left, fontSize: 20)
   
    
    init(muralItem: Mural) {
        super.init(nibName: nil, bundle: nil)
        self.muralItem = muralItem
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.addSubviews(imageView, authorLabelDescription, authorLabel, dateLabelDescription, dateLabel, userLabelDescription, userLabel)
        
        containerView.addSubviews(mapPinButton, dateLabelDescription, dateLabel, authorLabelDescription, authorLabel, sendEmailWithAuthorButton, userLabelDescription)
        view.addSubviews(imageView, containerView)
        
        
        configureViewController()
        checkAuthorPropertyInMuralItem()
        configureContainerView()
        configureUIElements()
        layoutUI()

    }
    
    func checkAuthorPropertyInMuralItem() {
        if let author = muralItem.author, author.isEmpty {
            authorLabel.isHidden = true
        } else {
            sendEmailWithAuthorButton.isHidden = true
        }
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
        userLabel.text = muralItem.addedBy
    }
    
    func layoutUI() {
        
        let horizontalPadding: CGFloat = 20
        let verticalPadding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            imageView.heightAnchor.constraint(equalToConstant: view.bounds.width / 3 * 4),
            
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
            
            authorLabel.topAnchor.constraint(equalTo: authorLabelDescription.bottomAnchor, constant: verticalPadding),
            authorLabel.leadingAnchor.constraint(equalTo: authorLabelDescription.leadingAnchor),
            authorLabel.heightAnchor.constraint(equalToConstant: 30),
            authorLabel.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 3 * 2),
            
            sendEmailWithAuthorButton.topAnchor.constraint(equalTo: authorLabelDescription.bottomAnchor),
            sendEmailWithAuthorButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalPadding),
            sendEmailWithAuthorButton.heightAnchor.constraint(equalToConstant: 30),
            sendEmailWithAuthorButton.widthAnchor.constraint(equalToConstant: 150),
            
            userLabelDescription.topAnchor.constraint(equalTo: sendEmailWithAuthorButton.bottomAnchor, constant: 20),
            userLabelDescription.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalPadding),
            userLabelDescription.heightAnchor.constraint(equalToConstant: 30),
            userLabelDescription.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 3 * 2)
            
    
        ])
        
        
        
        
        //Stary Layout
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            imageView.widthAnchor.constraint(equalToConstant: view.bounds.width),
//            imageView.heightAnchor.constraint(equalToConstant: view.bounds.width / 3 * 4),
//
//            authorLabelDescription.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: verticalPadding),
//            authorLabelDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
//            authorLabelDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalPadding),
//            authorLabelDescription.heightAnchor.constraint(equalToConstant: 15),
//
//            authorLabel.topAnchor.constraint(equalTo: authorLabelDescription.bottomAnchor, constant: 5),
//            authorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
//            authorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalPadding),
//            authorLabel.heightAnchor.constraint(equalToConstant: 30),
//
//            dateLabelDescription.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: verticalPadding),
//            dateLabelDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
//            dateLabelDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalPadding),
//            dateLabelDescription.heightAnchor.constraint(equalToConstant: 15),
//
//            dateLabel.topAnchor.constraint(equalTo: dateLabelDescription.bottomAnchor, constant: 5),
//            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
//            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalPadding),
//            dateLabel.heightAnchor.constraint(equalToConstant: 30),
//
//            userLabelDescription.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: verticalPadding),
//            userLabelDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
//            userLabelDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalPadding),
//            userLabelDescription.heightAnchor.constraint(equalToConstant: 15),
//
//            userLabel.topAnchor.constraint(equalTo: userLabelDescription.bottomAnchor, constant: 5),
//            userLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
//            userLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalPadding),
//            userLabel.heightAnchor.constraint(equalToConstant: 30),
//        ])
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    
    @objc func addToFavorite() {
        print("dodano do ULUBIONYCH")
    }
}
