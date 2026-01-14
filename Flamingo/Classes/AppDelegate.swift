//
//  AppDelegate.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 10/01/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize data
        SourceStore.shared.initializeFromBundleIfNeeded()
        
        // Setup appearance
        ThemeService.shared.updateTheme()
        ThemeService.shared.styleUIKit()
        
        // Screenshot mode
        if CommandLine.arguments.contains("screenshots") {
            UIView.setAnimationsEnabled(false)
            CustomPreferences.hasSetSources = true
            SourceStore.shared.setAllActivated(true)
        }
        
        // Setup initial view controller
        if let mainVC = R.storyboard.main.instantiateInitialViewController() {
            window?.rootViewController = mainVC
        }
        
        return true
    }
}
