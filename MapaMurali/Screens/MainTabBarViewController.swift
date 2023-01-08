//
//  TabViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 30/07/2022.
//

import UIKit
import FirebaseAuth
import RxSwift
import CoreLocation

class MainTabBarViewController: UITabBarController {
    
    //MARK: - Properties
    var loginManager: LoginManager
    var databaseManager: DatabaseManager
    var disposeBag = DisposeBag()

    //MARK: - Initialization
    
    init(loginManager: LoginManager, databaseManager: DatabaseManager) {
        self.loginManager = loginManager
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()

        let mapNC = UINavigationController(rootViewController: MapViewController(databaseManager: databaseManager))
        
        let collectionVC = MuralsCollectionViewController(databaseManager: databaseManager)
        collectionVC.title = "Przeglądaj"
        let collectionNC = UINavigationController(rootViewController: collectionVC)
        
        let addNC = UINavigationController(rootViewController: AddNewItemViewController(databaseManager: databaseManager))
        let statisticsNC = UINavigationController(rootViewController: StatisticsViewController(databaseManager: databaseManager))
        let accountNC = UINavigationController(rootViewController: UserAccountViewController(loginManager: loginManager, databaseManager: databaseManager))
        
        mapNC.tabBarItem.image = UIImage(systemName: "map")
        collectionNC.tabBarItem.image = UIImage(systemName: "photo.on.rectangle.angled")
        addNC.tabBarItem.image = UIImage(systemName: "plus")
        statisticsNC.tabBarItem.image = UIImage(systemName: "list.bullet")
        accountNC.tabBarItem.image = UIImage(systemName: "person")
        
        mapNC.title = "Mapa"
        collectionNC.title = "Murale"
        addNC.title = "Dodaj"
        statisticsNC.title = "Statystyki"
        accountNC.title = "Moje konto"
        
        collectionNC.isNavigationBarHidden = false
        collectionNC.navigationBar.prefersLargeTitles = true
        
        statisticsNC.isNavigationBarHidden = false
        statisticsNC.navigationBar.prefersLargeTitles = true
        
        let blur = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.bounds
        
        tabBar.addSubview(blurView)
        tabBar.tintColor = MMColors.primary
        
        setViewControllers([mapNC, collectionNC, addNC, statisticsNC, accountNC], animated: true)
        
        addMapPinButtonTappedObserver()
        addUserLoginObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    //MARK: - Logic
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            print("Validation IF User verification status: \(Auth.auth().currentUser?.isEmailVerified)")
            let destVC = SingInViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
            destVC.modalPresentationStyle = .fullScreen
            destVC.navigationController?.navigationBar.tintColor = MMColors.primary
            destVC.navigationController?.navigationBar.backItem?.title = "Zaloguj się"
            present(destVC, animated: false)
        } else {
            print("Validation ELSE User verification status: \(Auth.auth().currentUser?.isEmailVerified)")
//            Present VC with info about verification requirements if needed
            if FirebaseAuth.Auth.auth().currentUser?.isEmailVerified == false {
                loginManager.reloadUserStatus { success in
                    if success {
                        return
                    } else {
                        let destVC = VerificationEmailSendViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
                        destVC.modalPresentationStyle = .fullScreen
                        self.present(destVC, animated: false)
                    }
                }
            }
        }
    }
    
    //MARK: - Biding
    func addMapPinButtonTappedObserver() {
        databaseManager.mapPinButtonTappedOnMural
            .subscribe(onNext: { _ in
                self.selectedIndex = 0
            })
            .disposed(by: disposeBag)
    }
    
    func addUserLoginObserver() {
        loginManager.userIsLoggedIn
            .subscribe(onNext: { value in
                if value == true {
                    self.selectedViewController = self.viewControllers?[0]
                    self.databaseManager.fetchCurrenUserData()
                }
            })
            .disposed(by: disposeBag)
    }
}

