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
        icon.color = UIColor.orange
        var buttonAtts = attributes
        buttonAtts[.foregroundColor] = UIColor.orange
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
