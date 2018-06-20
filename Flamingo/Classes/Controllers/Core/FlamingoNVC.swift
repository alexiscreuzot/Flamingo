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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch self.theme {
        case .main, .transparent:
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    
    func updateUI() {
        
        let color = UIColor.black
        switch theme {
        case .main:
            self.navigationBar.isTranslucent = false
            break
        case .transparent:
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.backgroundColor = UIColor.clear
            self.navigationBar.isTranslucent = true
        }
        
        self.navigationBar.titleTextAttributes = [.foregroundColor: color]
        self.navigationBar.tintColor = color
    
        self.navigationBar.largeTitleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.black,
             NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]
        
        self.setNeedsStatusBarAppearanceUpdate()
    }

}
