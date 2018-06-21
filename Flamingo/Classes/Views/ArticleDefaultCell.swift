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

class ArticleDefaultCell: UITableViewCell{
    
    typealias OnCommentsAction = ((FlamingoPost) -> ())
    
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
        
        self.topInfoLabel.layer.cornerRadius = self.topInfoLabel.bounds.width / 2
        self.topInfoLabel.layer.masksToBounds = true
        
        let selView = UIView()
        selView.backgroundColor = UIColor.groupTableViewBackground
        self.selectedBackgroundView = selView
    }
    
    // MARK: - Logic
    
    func setPost(_ post : FlamingoPost, highlightComment: Bool = true) {
        
        self.topInfoTopMarginConstraint.constant = (post.row == 0) ? 30 : 16
        self.contentView.backgroundColor = UIColor.white
        
        if let subtitle = post.preview?.excerpt, !subtitle.isEmpty, subtitle != "null" {
            self.middleLabelTopMarginConstraint.constant = 10
            self.middleLabel.text = subtitle
        } else {
            self.middleLabelTopMarginConstraint.constant = 0
            self.middleLabel.text = ""
        }
                
        self.post = post
        self.contentView.alpha = post.isRead ? 0.3 : 1.0
        self.topInfoLabel.isHidden = false
        self.topInfoLabel.text = String(post.row + 1)
        self.titleLabel.text = post.hnPost.title
        
        let attributes: [NSAttributedStringKey : Any] = [.font : self.bottomLabel.font,
                                                         .foregroundColor : self.bottomLabel.textColor]
        self.bottomLabel.attributedText = post.infosAttributedString(attributes: attributes, withComments: false)
        self.commentsButton.setAttributedTitle(post.commentsAttributedString(attributes: attributes, highlightComment: true), for: .normal)
        self.commentsButton.isHidden = (post.hnPost.commentCount  == 0)
    }
    
    // MARK: - Actions

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.topInfoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.95)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.topInfoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.95)
    }
    
    @IBAction func selectComments() {
        guard let post = self.post else { return }
        self.delegate?.articleCell(self, didSelect: post)
    }
}
