//
//  UIKit+Extensions.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 07/02/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

// MARK: - UIColor

extension UIColor {
    
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - UIImage

extension UIImage {
    
    func blend(image: UIImage, with blendMode: CGBlendMode) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: CGPoint.zero)
        image.draw(in: CGRect(origin: CGPoint.zero, size: self.size), blendMode: blendMode, alpha: 0.9)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? UIImage()
    }
}

// MARK: - UIView

extension UIView {
    
    func allSubViewsOf<T: UIView>(type: T.Type) -> [T] {
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T {
                all.append(aView)
            }
            guard view.subviews.count > 0 else { return }
            view.subviews.forEach { getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}

// MARK: - CGFloat

extension CGFloat {
    
    var goldenRatio: (long: CGFloat, short: CGFloat) {
        let long = self / CGFloat(1.618)
        let short = self - long
        return (long, short)
    }
}

// MARK: - UIBezierPath

extension UIBezierPath {
    
    enum TriangleShape {
        case left(height: CGFloat)
        case middle(height: CGFloat)
        case right(height: CGFloat)
    }
    
    static func triangleMaskPath(rect: CGRect, type: TriangleShape) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        
        switch type {
        case .left(let height):
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY - height))
        case .middle(let height):
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - height))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        case .right(let height):
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - height))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        }
        path.close()
        return path
    }
}
