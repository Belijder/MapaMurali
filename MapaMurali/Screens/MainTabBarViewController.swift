//
//  TabViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 30/07/2022.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    var loginManager: LoginManager
    var databaseManager: DatabaseManager

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = UINavigationController(rootViewController: MapViewController(databaseManager: databaseManager))
        let vc2 = UINavigationController(rootViewController: AddNewItemViewController(databaseManager: databaseManager))
        let vc3 = UINavigationController(rootViewController: UserAccountViewController(loginManager: loginManager))
        
        vc1.tabBarItem.image = UIImage(systemName: "map")
        vc2.tabBarItem.image = UIImage(systemName: "plus")
        vc3.tabBarItem.image = UIImage(systemName: "person")
        
        vc1.title = "Mapa murali"
        vc2.title = "Dodaj mural"
        vc3.title = "Moje konto"
        
        let blur = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.bounds
        
        tabBar.addSubview(blurView)
        tabBar.tintColor = MMColors.primary
        
        setViewControllers([vc1, vc2, vc3], animated: true)
    }
    
    init(loginManager: LoginManager, databaseManager: DatabaseManager) {
        self.loginManager = loginManager
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

