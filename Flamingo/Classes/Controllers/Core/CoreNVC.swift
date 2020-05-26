//
//  CoreNVC.swift
//  rotoscopy
//
//  Created by Alexis Creuzot on 05/03/2020.
//  Copyright © 2020 monoqle. All rights reserved.
//

import Foundation
import UIKit

class CoreNVC : UINavigationController {
    
    public var isDismissable = true {
        didSet {
            for vc in self.viewControllers {
                guard let vc = vc as? CoreVC else { continue }
                vc.isDismissable = isDismissable
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
