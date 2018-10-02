//
//  UIKit+Extensions.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 07/02/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init (hex:String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            cString = "888888"
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}

extension UIView {
    
    /** This is the function to get subViews of a view of a particular type
     */
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }
    
    
    /** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}

extension CGFloat {
    var goldenRatio : (long: CGFloat, short:CGFloat) {
        let long = self / CGFloat(1.618)
        let short = self - long
        return (long, short)
    }
}

extension UIBezierPath {
    
    enum TriangleShape {
        case left(height: CGFloat)
        case middle(height: CGFloat)
        case right(height: CGFloat)
    }
    
    static func triangleMaskPath(rect: CGRect, type: TriangleShape) -> UIBezierPath{
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        
        switch type {
        case .left(let height):
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY - height))
            break
        case .middle(let height):
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - height))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
            break
        case .right(let height):
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - height))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
            break
        }
        path.close()
        return path
    }
    
}

extension UIImage {
    
    public convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
    func blend(image : UIImage, with blendMode:CGBlendMode) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at:  CGPoint.zero)
        image.draw(in: CGRect(origin: CGPoint.zero, size: self.size), blendMode: blendMode, alpha: 0.9)
        let result: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? UIImage()
    }
}
