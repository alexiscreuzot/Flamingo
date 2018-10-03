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
        case theme
    }
    
    public static var hasSetSources : Bool {
        get {
            return  (UserDefaults.standard.value(forKey: LocalDataKeys.hasSetSources.rawValue) as? Bool)
                    ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: LocalDataKeys.hasSetSources.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    public static var theme : Theme {
        get {
            let themeValue = UserDefaults.standard.integer(forKey: LocalDataKeys.theme.rawValue)
            return  Theme(rawValue: themeValue) ?? Theme.day
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: LocalDataKeys.theme.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
}
