//
//  UserDefaults+Extensions.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 07/06/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    private static let unallowedDomains = "unallowedDomains"
    
    var unallowedDomains : [String] {
        get {
            return self.object(forKey: UserDefaults.unallowedDomains) as? [String] ?? [String]()
        }
        set {
            self.set(newValue, forKey: UserDefaults.unallowedDomains)
            self.synchronize()
        }
    }
    
}
