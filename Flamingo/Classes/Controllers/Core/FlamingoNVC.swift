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
}

class FlamingoNVC : UINavigationController {
    
    var theme: FlamingoNavigationBarTheme = .main {
        didSet {
            self.updateUI()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch self.theme {
        case .main:
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    
    func updateUI() {
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        var color : UIColor!
        
        switch theme {
        case .main:
            color = UIColor.black
            break
        }
        
        self.navigationBar.titleTextAttributes = [.foregroundColor: color]
        self.navigationBar.tintColor = color
    
        self.navigationBar.largeTitleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.black,
             NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]
    }

}
