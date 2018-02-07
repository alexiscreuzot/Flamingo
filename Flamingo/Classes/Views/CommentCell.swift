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

protocol CommentCellDelegate {
    func commentCell(_ cell: CommentCell, didSelect url: URL)
}

class CommentCell: UITableViewCell, UITextViewDelegate {
    
    static let MaxLevels : Int = 6
    static let LevelOffset : CGFloat = 10
    static let LevelWidth : CGFloat = 2
    
    @IBOutlet var leftMarginConstraint : NSLayoutConstraint!
    @IBOutlet var topLabel : UILabel!
    @IBOutlet var createdLabel : UILabel!
    @IBOutlet var bodyTextView : UITextView!
    
    var levelViews = [UIView]()
    var delegate: CommentCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bodyTextView.delegate = self
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
        
        // Username
        let username = comment.username ?? i18n.articleCommentsCommentAnonymous()
        self.topLabel.text = username.removingHTMLEntities
        
        // Creation date
        if let created = comment.created {
             self.createdLabel.text = "• \(created)"
        } else {
            self.createdLabel.text = nil
        }
        
        // Body
        var content = comment.text ?? ""
        content.removingRegexMatches(pattern: "(<p>|</p>)", replaceWith: "\n\n")
 
        let attributes:[NSAttributedStringKey : Any] = [.font: self.bodyTextView.font!,
                                                        .foregroundColor: UIColor.darkGray]
        let modifier = modifierWithBaseAttributes(attributes, modifiers: [])
        let contentAttString = NSAttributedString.attributedStringFromMarkup(content, withModifier: modifier)
        self.bodyTextView.attributedText = contentAttString
        
        for _ in 1...level {
            let v = UIView()
            v.backgroundColor = UIColor.black
            self.levelViews.append(v)
            self.addSubview(v)
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.delegate?.commentCell(self, didSelect: URL)
        return false
    }
    
}
