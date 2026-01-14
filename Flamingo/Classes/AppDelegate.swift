//
//  AppDelegate.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 10/01/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

@main
class AppDelegate: PluggableApplicationDelegate {
    
    override var services: [ApplicationService] {
        return [
            ThemeService.shared,
            LocalDataService.shared,
            RoutingService.shared
        ]
    }
    
}

