//
//  File.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 05/02/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//


import UIKit
import HNScraper
import HTMLString
import Attributed

class CommentCell: UITableViewCell{
    
    static let MaxLevels : Int = 6
    static let LevelOffset : CGFloat = 10
    static let LevelWidth : CGFloat = 3
    
    @IBOutlet var leftMarginConstraint : NSLayoutConstraint!
    @IBOutlet var topLabel : UILabel!
    @IBOutlet var bodyTextView : UITextView!
    
    var levelViews = [UIView]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        for level in self.levelViews {
            level.removeFromSuperview()
        }
        self.levelViews = [UIView]()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for level in levelViews {
            guard let index = self.levelViews.index(of: level) else { continue }
            let indexFloat = CGFloat(index + 1)
            var frame = self.bounds
            frame.origin.x = (indexFloat * CommentCell.LevelOffset) - CommentCell.LevelWidth
            frame.size.width = CommentCell.LevelWidth
            level.frame = frame
        }
    }
    
    func setComment(_ comment: HNComment) {
        let level = min(comment.level + 1, CommentCell.MaxLevels)
        let leftInset = CGFloat(level) * CommentCell.LevelOffset
        self.leftMarginConstraint.constant = leftInset
        
        let username = comment.username ?? "Anonymous"
        var content = comment.text ?? ""
        content = content.replacingOccurrences(of: "<p>", with: "\n\n")
        content = content.replacingOccurrences(of: "</p>", with: "\n\n")
        self.removeChevronPrefix(&content)
        
        let attributes:[NSAttributedStringKey : Any] = [.font: self.bodyTextView.font!,
                                                        .foregroundColor: UIColor.darkGray]
        let modifier = modifierWithBaseAttributes(attributes, modifiers: [])
        let contentAttString = NSAttributedString.attributedStringFromMarkup(content, withModifier: modifier)
        self.topLabel.text = username.removingHTMLEntities
        self.bodyTextView.attributedText = contentAttString
        
        for _ in 1...level {
            let v = UIView()
            v.backgroundColor = UIColor.groupTableViewBackground
            self.levelViews.append(v)
            self.addSubview(v)
        }
    }
    
    func removeChevronPrefix(_ string : inout String) {
        if string.hasPrefix(">") {
            string.remove(at: string.startIndex)
            self.removeChevronPrefix(&string)
        }
    }
}
