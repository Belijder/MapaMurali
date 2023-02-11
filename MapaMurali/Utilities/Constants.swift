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
    static let placeholderImage = UIImage(named: "placeholder")
}


enum Setup {
    static let kFirebaseOpenAppScheme = "FirebaseOpenAppScheme"
    static let kFirebaseOpenAppURIPrefix = "FirebaseOpenAppURIPrefix"
    static let kFirebaseOpenAppQueryItemEmailName = "FirebaseOpenAppQueryItemEmailName"
    static let kEmail = "Email"
    static let kPassword = "Password"
    static var shouldOpenMailApp = false
}


enum RadiusValue {
    static let mapPinRadiusValue: CGFloat = 19
    static let muralCellRadiusValue: CGFloat = 20
}


enum ScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let maxLength = max(ScreenSize.width, ScreenSize.height)
    static let minLength = min(ScreenSize.width, ScreenSize.height)
}


enum DeviceTypes {
    static let idiom                    = UIDevice.current.userInterfaceIdiom
    static let nativeScale              = UIScreen.main.nativeScale
    static let scale                    = UIScreen.main.scale

    static let isiPhoneSE               = idiom == .phone && ScreenSize.maxLength == 568.0
    static let isiPhone8Standard        = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
    static let isiPhone8Zoomed          = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale > scale
    static let isiPhone8PlusStandard    = idiom == .phone && ScreenSize.maxLength == 736.0
    static let isiPhone8PlusZoomed      = idiom == .phone && ScreenSize.maxLength == 736.0 && nativeScale < scale
    static let isiPhoneX                = idiom == .phone && ScreenSize.maxLength == 812.0
    static let isiPhoneXsMaxAndXr       = idiom == .phone && ScreenSize.maxLength == 896.0
    static let isiPad                   = idiom == .pad && ScreenSize.maxLength >= 1024.0

    static func isiPhoneXAspectRatio() -> Bool {
        return isiPhoneX || isiPhoneXsMaxAndXr
    }
}
