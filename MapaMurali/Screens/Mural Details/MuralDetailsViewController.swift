//
//  MuralDetailsViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 08/10/2022.
//

import UIKit
import RxSwift

class MuralDetailsViewController: UIViewController {
    
    //MARK: - Properties
    private var muralItem: Mural!
    private var databaseManager: DatabaseManager!
    private let vm: MuralDetailsViewModel
    private var disposeBag = DisposeBag()
    
    private let muralInformationVC: MuralInformationVC
    
    let imageView = MMFullSizeImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 3 * 4))
    let containerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: 310))
    
    let closeButton = MMCircleButton(color: .white, systemImageName: "xmark")
    let favoriteButton = MMCircleButton(color: MMColors.primary)
    let mapPinButton = MMCircleButton(color: .white, systemImageName: "mappin.and.ellipse")
    let deleteMuralButton = MMCircleButton(color: .systemRed, systemImageName: "trash")
    
    
    //MARK: - Initialization
    init(muralItem: Mural, databaseManager: DatabaseManager, presentingVCTitle: String?) {
        self.vm = MuralDetailsViewModel(databaseManager: databaseManager, muralID: muralItem.docRef, counterValue: muralItem.favoritesCount, presentingVCTitle: presentingVCTitle)
        self.muralItem = muralItem
        self.databaseManager = databaseManager
        self.muralInformationVC = MuralInformationVC(muralItem: muralItem, databaseManager: databaseManager, presentingVCTitle: presentingVCTitle)
        super.init(nibName: nil, bundle: nil)
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
        add(childVC: muralInformationVC, to: containerView)
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
    

    private func configureUIElements() {
        if imageView.image == nil {
            imageView.downloadImage(from: muralItem.imageURL, imageType: .fullSize, docRef: muralItem.docRef)
        }
        
        imageView.contentMode = .scaleAspectFill
        let tap = UITapGestureRecognizer(target: self, action: #selector(openFullSizeImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
        
        mapPinButton.configuration?.baseBackgroundColor = MMColors.primary
        mapPinButton.addTarget(self, action: #selector(mapPinButtonTapped), for: .touchUpInside)
        
        configureDeleteButton()
        configureCloseButton()
        
        favoriteButton.set(systemImageName: vm.favoriteImageName)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
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
    
    
    private func layoutUI() {
        view.addSubviews(imageView, containerView, favoriteButton, closeButton, deleteMuralButton, mapPinButton)
        
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
            
            containerView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 310),
            
            deleteMuralButton.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -20),
            deleteMuralButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            deleteMuralButton.heightAnchor.constraint(equalToConstant: 44),
            deleteMuralButton.widthAnchor.constraint(equalToConstant: 44),
            
            mapPinButton.centerYAnchor.constraint(equalTo: containerView.topAnchor),
            mapPinButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -50),
            mapPinButton.heightAnchor.constraint(equalToConstant: 64),
            mapPinButton.widthAnchor.constraint(equalToConstant: 64),
        ])
    }
    
    
    //MARK: - Logic
    private func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    
    private func deleteMural() {
        guard NetworkMonitor.shared.isConnected == true else {
            presentMMAlert(title: "Brak połączenia", message: MMError.noConnectionDefaultMessage.rawValue)
            return
        }
        
        self.databaseManager.removeMural(for: muralItem.docRef) { success in
            if success == true {
                self.databaseManager.lastDeletedMuralID.onNext(self.muralItem.docRef)
                if let userID = self.databaseManager.currentUser?.id {
                    if self.muralItem.reviewStatus > 0 {
                        self.databaseManager.changeNumberOfMuralsAddedBy(user: userID, by: -1)
                    }
                }
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
        guard NetworkMonitor.shared.isConnected == true else {
            presentMMAlert(title: "Brak połączenia", message: MMError.noConnectionDefaultMessage.rawValue)
            return
        }
        
        vm.favoriteButtonTapped()
    }
    
    
    @objc private func mapPinButtonTapped() {
        databaseManager.mapPinButtonTappedOnMural.onNext(muralItem)
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    
    @objc private func openFullSizeImage() {
        guard let image = imageView.image else { return }
        let destVC = FullScreenImageVC(image: image)
        destVC.modalPresentationStyle = .fullScreen
        self.present(destVC, animated: true)
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
                self.muralInformationVC.favoriteCounter.createFavoriteCounterTextLabel(counter: self.vm.counterValue, imagePointSize: 25)
            })
            .disposed(by: disposeBag)
    }
    
    
    private func addLastEditedMuralsObserver() {
        databaseManager.lastEditedMuralID
            .subscribe(onNext: { editedMural in
                if editedMural.docRef == self.muralItem.docRef {
                    self.muralItem.address = editedMural.address
                    self.muralItem.city = editedMural.city
                    self.muralItem.author = editedMural.author
                }
            })
            .disposed(by: disposeBag)
    }
}
