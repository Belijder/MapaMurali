//
//  Constants.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 09/10/2022.
//

import UIKit

enum MMColors {
    static let primary = UIColor(named: "PrimaryTheme")!
    static let secondary = UIColor(named: "SecondaryTheme")!
    
    static let violetDark = UIColor(named: "VioletDark")!
    static let violetLight = UIColor(named: "VioletLight")!
    static let orangeDark = UIColor(named: "OrangeDark")!
    static let orangeLight = UIColor(named: "OrangeLight")!
}

enum MMImages {
    static let mmSignet = UIImage(named: "MMSignet")
    static let violetLogo = UIImage(named: "LogoViolet")
    static let addNewButton = UIImage(named: "addNewButton")
}

enum Setup {
    static let kFirebaseOpenAppScheme = "FirebaseOpenAppScheme"
    static let kFirebaseOpenAppURIPrefix = "FirebaseOpenAppURIPrefix"
    static let kFirebaseOpenAppQueryItemEmailName = "FirebaseOpenAppQueryItemEmailName"
    static let kEmail = "Email"
    static let kPassword = "Password"
    static var shouldOpenMailApp = false
}
