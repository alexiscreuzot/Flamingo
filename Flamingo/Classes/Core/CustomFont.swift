//
//  RotoscopyFont.swift
//  looq
//
//  Created by Alexis Creuzot on 14/11/2019.
//  Copyright © 2019 alexiscreuzot. All rights reserved.
//

import UIKit

enum CustomFont {
        
     case heading
       case title
       case callout
       case subtitle
       case body
       case footnote
       case icon
           
       var font : UIFont {
           
           switch self {
           case .heading:
               return boldFontAt(scale: 5)
           case .title:
               return boldFontAt(scale: 4)
           case .callout:
               return boldFontAt(scale: 2)
           case .subtitle:
               return lightFontAt(scale: 4)
           case .body:
               return fontAt(scale: 2)
           case .footnote:
               return boldFontAt(scale: 1)
           case .icon:
               return UIFont.init(name: "icomoon", size: 20)!
           }
       }
       
       private var base : CGFloat { return 12 }
       
       func lightFontAt(scale: Int) -> UIFont {
            let multiplier: CGFloat = pow(8/9, CGFloat(scale))
            return UIFont.systemFont(ofSize: base/multiplier, weight: .light)
       }
       func fontAt(scale: Int) -> UIFont {
           let multiplier: CGFloat = pow(8/9, CGFloat(scale))
           return UIFont.systemFont(ofSize: base/multiplier, weight: .regular)
       }
       func boldFontAt(scale: Int) -> UIFont {
           let multiplier: CGFloat = pow(8/9, CGFloat(scale))
           return UIFont.systemFont(ofSize: base/multiplier, weight: .bold)
       }
       
       func attributes(color: UIColor? = nil) -> [NSAttributedString.Key : Any] {
           let color = color ?? UIColor.label
           return [.foregroundColor: color,
           .backgroundColor: UIColor.clear,
           .font: self.font]
       }
       
       func attributedStringFor(_ string: String, color: UIColor? = nil) -> NSMutableAttributedString {
           return NSMutableAttributedString(string: string,
                                            attributes: self.attributes(color: color))
       }
}
