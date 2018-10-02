//
//  ThemService.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 02/10/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let themeDidChangeNotification = Notification.Name("themeDidChangeNotification")
}

enum Theme : Int {
    case day
    case night
    
    static var current : Theme {
        get {
            return Theme(rawValue: LocalData.theme) ?? .day
        }
        set {
            print("REFRESH THEME")
            LocalData.theme = newValue.rawValue
            print(self.themables)
            for themable in self.themables {
                themable.themeDidChange()
            }
        }
    }
    
    static var isNight : Bool {
        return self.current == .night
    }
    
    static var themables = [Themable]()
}

protocol Themable : NSObjectProtocol {
    func registerForThemeChange()
    func themeDidChange()
}

extension Themable {
    func registerForThemeChange(){
        guard !Theme.themables.contains(where: { $0 === self}) else {
            return
        }
        Theme.themables.append(self)
        self.themeDidChange()
    }
}
