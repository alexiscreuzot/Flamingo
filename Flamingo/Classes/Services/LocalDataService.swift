//
//  LocalDataService.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 27/09/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation

struct LocalData {
    
    enum LocalDataKeys : String, CodingKey{
        case hasSetSources
    }
    
    public var hasSetSources : Bool {
        get {
            return  (UserDefaults.standard.value(forKey: LocalDataKeys.hasSetSources.rawValue) as? Bool)
                    ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: LocalDataKeys.hasSetSources.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
}
