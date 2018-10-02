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
            LocalData.theme = newValue.rawValue
            NotificationCenter.default.post(name: .themeDidChangeNotification, object: nil)
        }
    }
}

@objc protocol Themable : NSObjectProtocol {
    func registerForThemeChange()
    @objc func themeDidChange()
}

extension Themable {
    func registerForThemeChange(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(themeDidChange),
                                               name: .themeDidChangeNotification,
                                               object: nil)
    }
}
