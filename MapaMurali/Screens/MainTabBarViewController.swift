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

