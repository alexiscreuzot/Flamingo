//
//  MaterialIcon.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 04/07/2019.
//  Copyright © 2019 alexiscreuzot. All rights reserved.
//

import UIKit

enum MaterialIcon: String {
    case clear = "\u{e999}"
    case check = "\u{eb53}"
    
    static func font(size: CGFloat) -> UIFont {
        return UIFont(name: "material-icons", size: size)!
    }
    
    func imageFor(size: CGFloat, color: UIColor) -> UIImage? {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .backgroundColor: UIColor.clear,
            .font: MaterialIcon.font(size: size)
        ]
        
        let imageSize = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        let rect = CGRect(origin: .zero, size: imageSize)
        rawValue.draw(in: rect, withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.withRenderingMode(.alwaysOriginal)
    }
}
