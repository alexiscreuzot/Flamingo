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

class ThemeStyle {
    var statusBarStyle : UIStatusBarStyle = .default
    var blurEffectStyle : UIBlurEffect.Style = .light
    var navigationBarStyle : UIBarStyle = .default
    var backgroundColor : UIColor = .white
    var secondaryBackgroundColor : UIColor = UIColor(white: 0.95, alpha: 1.0)
    var textColor : UIColor = .black
    var secondaryTextColor : UIColor = UIColor(white: 0.6, alpha: 1.0)
    var accentColor : UIColor = .orange
    var secondaryAccentColor : UIColor = .green
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
    
    var style : ThemeStyle {
        get {
            switch self {
            case .day:
                return ThemeStyle() // default is day
            case .night:
                let theme = ThemeStyle()
                theme.statusBarStyle = .lightContent
                theme.blurEffectStyle = .dark
                theme.navigationBarStyle = .black
                theme.backgroundColor = .black
                theme.secondaryBackgroundColor = UIColor(white: 0.05, alpha: 1.0)
                theme.textColor = .white
                theme.secondaryTextColor = UIColor(white: 0.4, alpha: 1.0)
                return theme
            }
        }
    }
    
}

