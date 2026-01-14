//
//  ThemeService.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 02/10/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

enum Theme : String, CaseIterable, Codable {
    case auto
    case dark
    case light
    
    var localized : String {
        switch self {
        case .auto:
            return i18n.settings_general_theme_auto()
        case .dark:
            return i18n.settings_general_theme_dark()
        case .light:
            return i18n.settings_general_theme_light()
        }
    }
    
    var statusBarStyle : UIStatusBarStyle {
        switch self {
        case .auto:
            return .default
        case .dark:
            return .lightContent
        case .light:
            return .darkContent
        }
    }
}

final class ThemeService: NSObject, ApplicationService {
    
    static let shared = ThemeService()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("🚀 ThemeService has started!")
        
//        self.printAvailableFonts()
        self.updateTheme()
        self.styleUIKit()
 
        return true
    }
    
    func printAvailableFonts() {
        UIFont.familyNames.sorted().forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName).sorted()
            print(familyName, fontNames)
        })
    }
    
    func styleUIKit() {
        UINavigationBar.appearance().tintColor = UIColor.label
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.label],
                                                            for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel],
                                                            for: .highlighted)
    }
    
    
    func updateTheme() {
        let currentTheme = CustomPreferences.colorTheme
        print("Set theme to \(currentTheme)")
        
        let style: UIUserInterfaceStyle
        switch currentTheme {
        case .auto:
            style = .unspecified
        case .dark:
            style = .dark
        case .light:
            style = .light
        }
        
        // Use the modern scene-based window access
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
    
}
