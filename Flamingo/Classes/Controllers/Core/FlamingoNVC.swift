//
//  FlamingoNVC.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 05/02/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation
import UIKit

class FlamingoNVC : UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.isNight ? .lightContent : .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForThemeChange()
    }
    
    func updateUI() {
        let color : UIColor = Theme.isNight ? .white : .black
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: color]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: color,
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]
        self.isNavigationBarHidden = true
        self.isNavigationBarHidden = false
        self.navigationBar.barStyle = Theme.isNight ? .black : .default
    }

}

extension FlamingoNVC : Themable {
    func themeDidChange() {
        self.updateUI()
    }
}
