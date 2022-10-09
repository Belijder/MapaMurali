//
//  MuralDetailsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 08/10/2022.
//

import UIKit

class MuralDetailsViewController: UIViewController {
    
    var muralItem: Mural!
    var imageView = MMFullSizeImageView(frame: .zero)
    var authorLabelDescription = MMBodyLabel(textAlignment: .left)
    var authorLabel = MMTitleLabel(textAlignment: .left, fontSize: 20)
    var dateLabelDescription = MMBodyLabel(textAlignment: .left)
    var dateLabel = MMTitleLabel(textAlignment: .left, fontSize: 20)
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
        view.addSubviews(imageView, authorLabelDescription, authorLabel, dateLabelDescription, dateLabel, userLabelDescription, userLabel)
        configureViewController()
        configureUIElements()
        layoutUI()

    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.tintColor = .systemGreen
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.leftBarButtonItem = closeButton
        
        let addToFavoriteButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(addToFavorite))
        navigationItem.rightBarButtonItem = addToFavoriteButton
    }
    
    func configureUIElements() {
        imageView.downloadImage(from: muralItem.imageURL)
        authorLabelDescription.text = "Autor:"
        authorLabel.text = muralItem.author!.isEmpty || muralItem.author == nil ? "Brak informacji" : muralItem.author
        dateLabelDescription.text = "Data dodania:"
        dateLabel.text = muralItem.addedDate.convertToDayMonthYearFormat()
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
            
            authorLabelDescription.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: verticalPadding),
            authorLabelDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            authorLabelDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalPadding),
            authorLabelDescription.heightAnchor.constraint(equalToConstant: 15),
            
            authorLabel.topAnchor.constraint(equalTo: authorLabelDescription.bottomAnchor, constant: 5),
            authorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            authorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalPadding),
            authorLabel.heightAnchor.constraint(equalToConstant: 30),
            
            dateLabelDescription.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: verticalPadding),
            dateLabelDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            dateLabelDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalPadding),
            dateLabelDescription.heightAnchor.constraint(equalToConstant: 15),
            
            dateLabel.topAnchor.constraint(equalTo: dateLabelDescription.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalPadding),
            dateLabel.heightAnchor.constraint(equalToConstant: 30),
            
            userLabelDescription.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: verticalPadding),
            userLabelDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            userLabelDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalPadding),
            userLabelDescription.heightAnchor.constraint(equalToConstant: 15),
            
            userLabel.topAnchor.constraint(equalTo: userLabelDescription.bottomAnchor, constant: 5),
            userLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            userLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalPadding),
            userLabel.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    
    @objc func addToFavorite() {
        print("dodano do ULUBIONYCH")
    }
}
