//
//  SceneDelegate.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 10/01/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
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
        
        // Setup window and initial view controller
        window = UIWindow(windowScene: windowScene)
        if let mainVC = R.storyboard.main.instantiateInitialViewController() {
            window?.rootViewController = mainVC
        }
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
