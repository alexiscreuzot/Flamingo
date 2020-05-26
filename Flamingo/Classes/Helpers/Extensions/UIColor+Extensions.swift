//
//  UIColor+Extensions.swift
//  looq
//
//  Created by Alexis Creuzot on 14/08/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

extension UIColor {
    
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    var contrastColor: UIColor {
        get {
            // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
            let components = self.cgColor.components!
            let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
            return (brightness < 0.5) ? UIColor.white : UIColor.black
        }
    }
}
