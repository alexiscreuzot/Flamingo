//
//  FlamingoPost.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 05/02/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation
import HNScraper

struct FlamingoPost {
    
    var hnPost : HNPost!
    var preview : Preview?
    var row : Int
    
    init(hnPost: HNPost, preview: Preview? = nil, row : Int) {
        self.hnPost = hnPost
        self.preview = preview
        self.row = row
    }
    
    func infosAttributedString(attributes: [NSAttributedStringKey : Any], withComments: Bool = false) -> NSAttributedString {
        
        let bottomAttString = NSMutableAttributedString(string: "\(hnPost.urlDomain)", attributes: attributes)
        
        // Readtime
        if let minutes = self.preview?.readTimeInMinutes {
            let readAttString = NSMutableAttributedString(string: " • ", attributes: attributes)
            let icon = FontIcon(.clock)
            icon.color = attributes[.foregroundColor] as! UIColor
            readAttString.append(icon.attributedString)
            readAttString.append(NSAttributedString(string: " \(minutes) min"))
            bottomAttString.append(readAttString)
        }
        
        if withComments {
            bottomAttString.append(self.commentsAttributedString(attributes: attributes))
        }
        
        return bottomAttString
    }
    
    func commentsAttributedString(attributes: [NSAttributedStringKey : Any]) -> NSAttributedString {
        // Comments
        let commentsAttString = NSMutableAttributedString(string: " • ", attributes: attributes)
        let icon = FontIcon(.commentBubble)
        icon.color = attributes[.foregroundColor] as! UIColor
        commentsAttString.append(icon.attributedString)
        commentsAttString.append(NSAttributedString(string: " \(hnPost.commentCount)  ", attributes : attributes))
        return commentsAttString
    }
}
