//
//  Extensions.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 30/01/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var wordCount : Int {
        let words = self.components(separatedBy: .whitespacesAndNewlines)
        return words.count
    }
    
    var tagless : String {
        var words = self.components(separatedBy: .whitespacesAndNewlines)
        words = words.filter { string -> Bool in
            return !(string.contains("<") && (string.contains(">")))
        }
        return words.joined(separator: " ")
    }
}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        precondition(indices.contains(from) && indices.contains(to), "invalid indexes")
        insert(remove(at: from), at: to)
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
