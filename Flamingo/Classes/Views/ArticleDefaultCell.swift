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
    func articleCell(_ cell: ArticleDefaultCell, didSelect post: FlamingoPost)
}

class ArticleDefaultCell: UITableViewCell {
    
    typealias OnCommentsAction = ((FlamingoPost) -> ())
    
    @IBOutlet var topInfoHolderView : UIView!
    @IBOutlet var topInfoTopMarginConstraint : NSLayoutConstraint!
    @IBOutlet var topInfoLabel : UILabel!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var middleLabel : UILabel!
    @IBOutlet var middleLabelTopMarginConstraint : NSLayoutConstraint!
    @IBOutlet var bottomLabel : UILabel!
    @IBOutlet var commentsButton : UIButton!
    
    var post : FlamingoPost?
    var delegate: ArticleDefaultCellDelegate?
    let maskLayer = CAShapeLayer()
    var is3DTouchAvailable: Bool {
        return traitCollection.forceTouchCapability == .available
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.topInfoLabel.layer.masksToBounds = true
        self.selectedBackgroundView = UIView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.topInfoLabel.layer.cornerRadius = self.topInfoLabel.bounds.width / 2
    }
    
    // MARK: - Logic
    
    func setPost(_ post : FlamingoPost, highlightComment: Bool = true) {
        
        self.selectedBackgroundView?.backgroundColor = Theme.current.style.secondaryBackgroundColor
        
        self.applyTheme()
        self.topInfoTopMarginConstraint.constant = (post.row == 0) ? 30 : 16
        
        if let subtitle = post.preview?.excerpt, !subtitle.isEmpty, subtitle != "null" {
            self.middleLabelTopMarginConstraint.constant = 10
            self.middleLabel.text = subtitle
        } else {
            self.middleLabelTopMarginConstraint.constant = 0
            self.middleLabel.text = ""
        }
                
        self.post = post

        self.topInfoLabel.isHidden = false
        self.topInfoLabel.text = String(post.row + 1)
        self.titleLabel.text = post.hnPost.title
        
        let attributes: [NSAttributedString.Key : Any] = [.font : self.bottomLabel.font,
                                                         .foregroundColor : self.bottomLabel.textColor]
        self.bottomLabel.attributedText = post.infosAttributedString(attributes: attributes, withPointSize:self.bottomLabel.font.pointSize, withComments: false)
        
        self.commentsButton.setAttributedTitle(post.commentsAttributedString(attributes: attributes,
                                                                             withPointSize: self.commentsButton.titleLabel!.font.pointSize,
                                                                             highlightComment: true), for: .normal)
        self.commentsButton.isHidden = (post.hnPost.commentCount  == 0)
        self.contentView.alpha = post.isRead ? 0.3 : 1.0
    }
    
    func applyTheme() {
        self.backgroundColor = Theme.current.style.backgroundColor
        self.contentView.backgroundColor = Theme.current.style.backgroundColor
        self.titleLabel.textColor = Theme.current.style.textColor
        self.middleLabel.textColor = Theme.current.style.secondaryTextColor
    }
    
    // MARK: - Actions

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        self.topInfoLabel.backgroundColor = Theme.current.style.textColor
        self.topInfoLabel.textColor = Theme.current.style.backgroundColor
    }
    
    @IBAction func selectComments() {
        guard let post = self.post else { return }
        self.delegate?.articleCell(self, didSelect: post)
    }
}
