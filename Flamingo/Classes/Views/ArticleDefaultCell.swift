//
//  ArticleDefaultCell.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 10/01/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit
import HNScraper

protocol ArticleDefaultCellDelegate {
    func didSelectComments(post: HNPost)
}

class ArticleDefaultCell: UITableViewCell{
    
    typealias OnCommentsAction = ((HNPost) -> ())
    
    var post : HNPost?
    var row : Int?
    var delegate: ArticleDefaultCellDelegate?
    let maskLayer = CAShapeLayer()
    
    @IBOutlet var topInfoTopMarginConstraint : NSLayoutConstraint!
    @IBOutlet var topInfoLabel : UILabel!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var middleLabel : UILabel!
    @IBOutlet var middleLabelTopMarginConstraint : NSLayoutConstraint!
    @IBOutlet var bottomLabel : UILabel!
    @IBOutlet var commentsButton : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.topInfoLabel.layer.cornerRadius = self.topInfoLabel.bounds.width / 2
        self.topInfoLabel.layer.masksToBounds = true
        
        let selView = UIView()
        selView.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        self.selectedBackgroundView = selView
    }
    
    func setPost(_ post: HNPost, preview: Preview?, row: Int) {
        self.row = row
        
        self.topInfoTopMarginConstraint.constant = (row == 0) ? 30 : 16
        self.contentView.backgroundColor = UIColor.white
        
        if let subtitle = preview?.excerpt, !subtitle.isEmpty, subtitle != "null" {
            self.middleLabelTopMarginConstraint.constant = 10
            self.middleLabel.text = subtitle
        } else {
            self.middleLabelTopMarginConstraint.constant = 0
            self.middleLabel.text = ""
        }
                
        self.post = post
        self.topInfoLabel.isHidden = false
        self.topInfoLabel.text = String(row + 1)
        self.titleLabel.text = post.title
        
        let attributes: [NSAttributedStringKey : Any] = [.font : self.bottomLabel.font,
                                                         .foregroundColor : self.bottomLabel.textColor]
        let bottomAttString = NSMutableAttributedString(string: "\(post.urlDomain)", attributes: attributes)
        
        // Readtime
        if let minutes = preview?.readTimeInMinutes {
            let readAttString = NSMutableAttributedString(string: " • ", attributes: attributes)
            let icon = FontIcon(.clock)
            icon.color = self.bottomLabel.textColor
            readAttString.append(icon.attributedString)
            readAttString.append(NSAttributedString(string: " \(minutes) min"))
            bottomAttString.append(readAttString)
        }
        self.bottomLabel.attributedText = bottomAttString
        
        // Comments
        let commentsAttString = NSMutableAttributedString(string: " • ", attributes: attributes)
        let icon = FontIcon(.commentBubble)
        icon.color = self.bottomLabel.textColor
        commentsAttString.append(icon.attributedString)
        
        commentsAttString.append(NSAttributedString(string: " \(post.commentCount)  ", attributes : attributes))
        self.commentsButton.setAttributedTitle(commentsAttString, for: .normal)
        self.commentsButton.isHidden = (post.commentCount  == 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.topInfoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.95)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.topInfoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.95)
    }
    
    @IBAction func selectComments() {
        guard let post = self.post else {
            return
        }
        self.delegate?.didSelectComments(post: post)
    }
}
