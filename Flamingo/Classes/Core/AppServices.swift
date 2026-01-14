//
//  AppServices.swift
//  Flamingo
//
//  Native replacement for PluggableAppDelegate
//

import UIKit

// MARK: - Application Service Protocol

protocol ApplicationService: AnyObject {
    var window: UIWindow? { get set }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
    func applicationWillResignActive(_ application: UIApplication)
    func applicationDidEnterBackground(_ application: UIApplication)
    func applicationWillEnterForeground(_ application: UIApplication)
    func applicationDidBecomeActive(_ application: UIApplication)
    func applicationWillTerminate(_ application: UIApplication)
}

// Default implementations
extension ApplicationService {
    var window: UIWindow? {
        get { nil }
        set { }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { true }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool { true }
    func applicationWillResignActive(_ application: UIApplication) { }
    func applicationDidEnterBackground(_ application: UIApplication) { }
    func applicationWillEnterForeground(_ application: UIApplication) { }
    func applicationDidBecomeActive(_ application: UIApplication) { }
    func applicationWillTerminate(_ application: UIApplication) { }
}

// MARK: - Pluggable App Delegate Base Class

class PluggableApplicationDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var services: [ApplicationService] {
        return []
    }
    
    private lazy var _services: [ApplicationService] = {
        return services
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        for service in _services {
            service.window = window
            _ = service.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        for service in _services {
            if service.application(app, open: url, options: options) {
                return true
            }
        }
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        for service in _services {
            service.applicationWillResignActive(application)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        for service in _services {
            service.applicationDidEnterBackground(application)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        for service in _services {
            service.applicationWillEnterForeground(application)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        for service in _services {
            service.applicationDidBecomeActive(application)
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        for service in _services {
            service.applicationWillTerminate(application)
        }
    }
}
