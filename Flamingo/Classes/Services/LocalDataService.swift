//
//  LocalDataService.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 27/09/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation
import PluggableAppDelegate
import RealmSwift

final class LocalDataService: NSObject, ApplicationService {
    
    static let shared = LocalDataService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        Realm.Configuration.defaultConfiguration = config
        
        // Init sources if needed
        let realm = try! Realm()
        let localSources = realm.objects(Source.self)
        if localSources.isEmpty {
            JSONSerializer.serializeSources()
        }
        
        if CommandLine.arguments.contains("screenshots") {
            self.prepareScreenshots()
        }
        
        print("🚀 LocalDataService has started!")
                
        return true
    }
    
    func prepareScreenshots() {
        UIView.setAnimationsEnabled(false)
        let realm = try! Realm()
        CustomPreferences.hasSetSources = true
        try! realm.write {
            for source in realm.objects(Source.self) {
                source.activated = true
            }
        }
    }
    
}
