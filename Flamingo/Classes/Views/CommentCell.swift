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
import TTTAttributedLabel

protocol CommentCellDelegate {
    func commentCell(_ cell: CommentCell, didSelect url: URL)
}

class CommentCell: UITableViewCell, TTTAttributedLabelDelegate {
    
    static let MaxLevels : Int = 6
    static let LevelOffset : CGFloat = 10
    static let LevelWidth : CGFloat = 2
    
    @IBOutlet var leftMarginConstraint : NSLayoutConstraint!
    @IBOutlet var holderView : UIView!
    @IBOutlet var topLabel : UILabel!
    @IBOutlet var createdLabel : UILabel!
    @IBOutlet var bodyTextLabel : TTTAttributedLabel!
    
    var levelViews = [UIView]()
    var delegate: CommentCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bodyTextLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        self.bodyTextLabel.delegate = self
        self.bodyTextLabel.linkAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
        
        let selView = UIView()
        selView.backgroundColor = UIColor.groupTableViewBackground
        self.selectedBackgroundView = selView
        
        // Create levels
        for _ in 1...CommentCell.MaxLevels {
            let v = UIView()
            v.backgroundColor = UIColor.black
            self.levelViews.append(v)
            self.contentView.insertSubview(v, at: 0)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for (index, level) in levelViews.enumerated() {
            let indexFloat = CGFloat(index + 1)
            var frame = self.bounds
            frame.origin.x = (indexFloat * CommentCell.LevelOffset) - CommentCell.LevelWidth
            frame.size.width = CommentCell.LevelWidth
            level.frame = frame
        }
    }
    
    func setComment(_ comment: HNComment, isCollapser : Bool = false) {
        
        let backgroundColor = Theme.isNight ? UIColor.black : UIColor.white
        let primarytextColor = Theme.isNight ? UIColor.white : UIColor.black
        let secondarytextColor = Theme.isNight ? UIColor.lightGray : UIColor.darkGray
        
        self.backgroundColor = backgroundColor
        self.contentView.backgroundColor = backgroundColor
        self.holderView.backgroundColor = backgroundColor
        self.topLabel.textColor = primarytextColor
        
        let level = min(comment.level + 1, CommentCell.MaxLevels)
        let leftInset = CGFloat(level) * CommentCell.LevelOffset
        self.leftMarginConstraint.constant = leftInset
        
        // Username
        let username = comment.username ?? i18n.articleCommentsCommentAnonymous()
        self.topLabel.text = username.removingHTMLEntities
        
        let color = isCollapser ? UIColor.orange : primarytextColor
        self.selectionStyle = isCollapser ? .default : .none
        for level in self.levelViews {
            level.backgroundColor = color
        }
        
        // Creation date
        if let created = comment.created {
             self.createdLabel.text = "• \(created)"
        } else {
            self.createdLabel.text = nil
        }
        self.createdLabel.textColor = secondarytextColor
        
        // Body
        var content = comment.text ?? ""
        content.removingRegexMatches(pattern: "(<p>|</p>)", replaceWith: "\n\n")
 
        
        let attributes:[NSAttributedString.Key : Any] = [.font: self.bodyTextLabel.font!,
                                                        .foregroundColor: secondarytextColor]
        let modifier = modifierWithBaseAttributes(attributes, modifiers: [])
        let contentAttString = NSAttributedString.attributedStringFromMarkup(content, withModifier: modifier)
        self.bodyTextLabel.setText(contentAttString)
    }
    
    // MARK: - TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        self.delegate?.commentCell(self, didSelect: url)
    }

}
