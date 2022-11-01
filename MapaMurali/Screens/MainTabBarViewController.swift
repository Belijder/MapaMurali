//
//  TabViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 30/07/2022.
//

import UIKit
import FirebaseAuth

class MainTabBarViewController: UITabBarController {
    
    var loginManager = LoginManager()
    var databaseManager = DatabaseManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapVC = UINavigationController(rootViewController: MapViewController(databaseManager: databaseManager))
        let collectionVC = UINavigationController(rootViewController: MuralsCollectionViewController(databaseManager: databaseManager))
        let addVC = UINavigationController(rootViewController: AddNewItemViewController(databaseManager: databaseManager))
        let statisticsVC = UINavigationController(rootViewController: StatisticsViewController(databaseManager: databaseManager))
        let accountVC = UINavigationController(rootViewController: UserAccountViewController(loginManager: loginManager, databaseManager: databaseManager))
        
        mapVC.tabBarItem.image = UIImage(systemName: "map")
        collectionVC.tabBarItem.image = UIImage(systemName: "photo.on.rectangle.angled")
        addVC.tabBarItem.image = UIImage(systemName: "plus")
        statisticsVC.tabBarItem.image = UIImage(systemName: "list.bullet")
        accountVC.tabBarItem.image = UIImage(systemName: "person")
        
        mapVC.title = "Mapa"
        collectionVC.title = "Murale"
        addVC.title = "Dodaj"
        statisticsVC.title = "Statystyki"
        accountVC.title = "Moje konto"
        
        statisticsVC.isNavigationBarHidden = false
        statisticsVC.navigationBar.prefersLargeTitles = true
        
        let blur = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.bounds
        
        tabBar.addSubview(blurView)
        tabBar.tintColor = MMColors.primary
        
        setViewControllers([mapVC, collectionVC, addVC, statisticsVC, accountVC], animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = SingInViewController(loginManager: self.loginManager, databaseManager: self.databaseManager)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            nav.navigationBar.tintColor = MMColors.primary
            nav.navigationBar.backItem?.title = "Zaloguj się"
            present(nav, animated: false)
        }
    }
}

