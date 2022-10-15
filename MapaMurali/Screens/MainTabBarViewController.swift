//
//  TabViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 30/07/2022.
//

import UIKit
import RxSwift
import FirebaseAuth

class MainTabBarViewController: UITabBarController {
    
    var loginManager = LoginManager()
    var databaseManager = DatabaseManager()
    var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let vc1 = UINavigationController(rootViewController: MapViewController(databaseManager: databaseManager))
        let vc2 = UINavigationController(rootViewController: AddNewItemViewController(databaseManager: databaseManager))
        let vc3 = UINavigationController(rootViewController: UserAccountViewController(loginManager: loginManager))
        let vc4 = UINavigationController(rootViewController: MuralsCollectionViewController(databaseManager: databaseManager))
        
        vc1.tabBarItem.image = UIImage(systemName: "map")
        vc2.tabBarItem.image = UIImage(systemName: "plus")
        vc3.tabBarItem.image = UIImage(systemName: "person")
        vc4.tabBarItem.image = UIImage(systemName: "photo.on.rectangle.angled")
        
        vc1.title = "Mapa"
        vc2.title = "Dodaj"
        vc3.title = "Moje konto"
        vc4.title = "Murale"
        
        let blur = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.bounds
        
        tabBar.addSubview(blurView)
        tabBar.tintColor = MMColors.primary
        
        setViewControllers([vc1, vc4, vc2, vc3], animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = SingInViewController(loginManager: self.loginManager)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
}

