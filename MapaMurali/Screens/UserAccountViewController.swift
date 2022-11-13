//
//  UserAccountViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 30/07/2022.
//

import UIKit

class UserAccountViewController: UIViewController {
    
    var loginManager: LoginManager
    let databaseManager: DatabaseManager
    
    var userAddedMurals = [Mural]()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let usernameAndAvatar = MMUsernameWithAvatarView(imageHeight: 100)
    
    let userAddedMuralsCollectionView = UIView()
    
    private let logOutButton: UIButton = {
        let button = UIButton(configuration: .tinted(), primaryAction: nil)
        button.setTitle("Logout", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        configureUsernameAndAvatarView()
        layoutUI()
        configureCollectionsViews()

        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
    }
    
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.pinToEdges(of: view)
        contentView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 900)
        ])
    }
    
    func configureUsernameAndAvatarView() {
        guard let userID = loginManager.currentUserID else { return }
        databaseManager.fetchUserFromDatabase(id: userID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.usernameAndAvatar.username.text = user.displayName
                    self.usernameAndAvatar.avatarView.setImage(from: user.avatarURL)
                case .failure(let error):
                    print("🔴 Error to fetch users info from Database. Error: \(error)")
                    self.usernameAndAvatar.username.text = "brak nazwy"
                }
            }
        }
        
        self.usernameAndAvatar.username.font = UIFont.systemFont(ofSize: 30, weight: .bold)
    }
    
    func configureCollectionsViews() {
        userAddedMurals = databaseManager.murals.filter { $0.addedBy == loginManager.currentUserID }
        add(childVC: MMUserAddedMuralsCollectionsVC(collectionName: "Nowe", murals: userAddedMurals), to: self.userAddedMuralsCollectionView)
        
    }
    
    func layoutUI() {
        contentView.addSubviews(usernameAndAvatar, userAddedMuralsCollectionView)
        
        userAddedMuralsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 20
        let sectionPadding: CGFloat = 30
        
        NSLayoutConstraint.activate([
            usernameAndAvatar.topAnchor.constraint(equalTo: contentView.topAnchor),
            usernameAndAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            usernameAndAvatar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            usernameAndAvatar.heightAnchor.constraint(equalToConstant: 100),
            
//            logOutButton.topAnchor.constraint(equalTo: usernameAndAvatar.bottomAnchor, constant: sectionPadding),
//            logOutButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            logOutButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            userAddedMuralsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            userAddedMuralsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            userAddedMuralsCollectionView.topAnchor.constraint(equalTo: usernameAndAvatar.bottomAnchor, constant: sectionPadding),
            userAddedMuralsCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
        ])
    }
    
    
    @objc func logOut(_ sender: UIButton!) {
        loginManager.singOut()
        let vc = SingInViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: false)
    }
    

    
    init(loginManager: LoginManager, databaseManager: DatabaseManager) {
        self.loginManager = loginManager
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
}

//extension UserAccountViewController: MMUserAddedMuralsCollectionsDelegate {
//    func didTapManageAddedMurals() {
//        print("🟢 Manage User Added Murals Button Tapped!")
//    }
    
    
    
//}
