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
    var isRead: Bool = false {
        didSet {
            hnPost.isRead = isRead
        }
    }
    
    init(hnPost: HNPost, preview: Preview? = nil, row : Int) {
        self.hnPost = hnPost
        self.preview = preview
        self.row = row
        self.isRead = hnPost.isRead //cache it for smoothest scrolling
    }
    
    func infosAttributedString(attributes: [NSAttributedString.Key : Any], withPointSize: CGFloat, withComments: Bool) -> NSAttributedString {
        
        let bottomAttString = NSMutableAttributedString(string: "\(hnPost.urlDomain)", attributes: attributes)
        
        // Readtime
        if let minutes = self.preview?.readTimeInMinutes {
            let readAttString = NSMutableAttributedString(string: " • ", attributes: attributes)
            let icon = FontIcon(.clock)
            icon.color = attributes[.foregroundColor] as! UIColor
            icon.pointSize = withPointSize * 0.8
            readAttString.append(icon.attributedString)
            readAttString.append(NSAttributedString(string: " \(minutes) min"))
            bottomAttString.append(readAttString)
        }
        
        if withComments {
            bottomAttString.append(self.commentsAttributedString(attributes: attributes, withPointSize: withPointSize, highlightComment: false))
        }
        
        return bottomAttString
    }
    
    func commentsAttributedString(attributes: [NSAttributedString.Key : Any], withPointSize: CGFloat, highlightComment: Bool) -> NSAttributedString {
        // Comments
        let commentsAttString = NSMutableAttributedString(string: " • ", attributes: attributes)
        let icon = FontIcon(.commentBubble)
        
        var buttonAtts = attributes
        if highlightComment {
            buttonAtts[.foregroundColor] = CustomColor.primary
        }

        icon.color = buttonAtts[.foregroundColor] as! UIColor
        icon.pointSize = withPointSize * 0.8
        commentsAttString.append(icon.attributedString)
        commentsAttString.append(NSAttributedString(string: " \(hnPost.commentCount)  ", attributes : buttonAtts))
        return commentsAttString
    }

}

/// Add the read persistency on HNPost
extension HNPost {

    var isRead: Bool {
        get {
            guard let readIds = UserDefaults.standard.value(forKey: String.readStatusKey) as? Array<String> else {
                return false    //fail gracefully (previous behavior)
            }

            return readIds.contains(id)
        }
        set {
            guard var readIds = UserDefaults.standard.value(forKey: String.readStatusKey) as? Array<String> else {
                UserDefaults.standard.set([id], forKey: String.readStatusKey)
                return
            }

            if !readIds.contains(id) {
                readIds.append(id)
                UserDefaults.standard.set(readIds, forKey: String.readStatusKey)
            }
        }
    }
}

private extension String {

  static let readStatusKey = "read_status_key"
}
