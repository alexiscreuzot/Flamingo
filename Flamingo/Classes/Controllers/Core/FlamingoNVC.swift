//
//  FlamingoNVC.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 05/02/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation
import UIKit

enum FlamingoNavigationBarTheme {
    case main
    case transparent
}

class FlamingoNVC : UINavigationController {
    
    var theme: FlamingoNavigationBarTheme = .main {
        didSet {
            self.updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForThemeChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }
    
    func updateUI() {
        let color = Theme.current.style.textColor
        self.navigationBar.barStyle = Theme.current.style.navigationBarStyle
        switch theme {
        case .main:
            break
        case .transparent:
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.backgroundColor = UIColor.clear
            self.navigationBar.isTranslucent = true
        }
        
        self.navigationBar.tintColor = color
        self.navigationBar.titleTextAttributes = [.foregroundColor: color]
        self.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor: color,
             NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]        
    }

}

extension FlamingoNVC : Themable {
    func themeDidChange() {
        self.updateUI()
    }
}

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
}
