//
//  RoutingService.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 29/08/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

final class RoutingService: NSObject, ApplicationService {
    
    static let shared = RoutingService()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("🚀 RoutingService has started!")
        self.mainSetup()
        
        return true
    }
    
    // MARK: - openURL handling
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        self.mainSetup()
        return true
    }
    
    func mainSetup() {
        let mainNavController = R.storyboard.main.instantiateInitialViewController()!
        if let window = self.window {
            window.rootViewController = mainNavController
        }
    }
    
}
