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
        
        var bottomText = "\(post.urlDomain)"
        if let minutes = preview?.readTimeInMinutes {
            bottomText += " • \(minutes) min read"
        }
        self.bottomLabel.text = bottomText
        
        let commentString = post.commentCount == 1 ? "comment" : "comments"
        self.commentsButton.setTitle("• \(post.commentCount) \(commentString)", for: .normal)
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
