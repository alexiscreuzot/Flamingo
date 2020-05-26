//
//  LooqPreferences.swift
//  looq
//
//  Created by Alexis Creuzot on 15/11/2019.
//  Copyright © 2019 alexiscreuzot. All rights reserved.
//

import Foundation

struct CustomPreferences {
        
    @Storage(key: "colorTheme", defaultValue: Theme.auto)
    static var colorTheme: Theme
    
    @Storage(key: "hasSetSources", defaultValue: false)
    static var hasSetSources: Bool

}
