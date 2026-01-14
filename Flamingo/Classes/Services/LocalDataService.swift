//
//  LocalDataService.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 27/09/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

final class LocalDataService: NSObject, ApplicationService {
    
    static let shared = LocalDataService()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Init sources if needed
        SourceStore.shared.initializeFromBundleIfNeeded()
        
        if CommandLine.arguments.contains("screenshots") {
            self.prepareScreenshots()
        }
        
        print("🚀 LocalDataService has started!")
                
        return true
    }
    
    func prepareScreenshots() {
        UIView.setAnimationsEnabled(false)
        CustomPreferences.hasSetSources = true
        SourceStore.shared.setAllActivated(true)
    }
    
}
