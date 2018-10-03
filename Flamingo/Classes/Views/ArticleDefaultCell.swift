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
        
        let selView = UIView()
        selView.backgroundColor = Theme.isNight ? UIColor(white: 0.05, alpha: 1) : UIColor(white: 0.95, alpha: 1)
        self.selectedBackgroundView = selView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.topInfoLabel.layer.cornerRadius = self.topInfoLabel.bounds.width / 2
    }
    
    // MARK: - Logic
    
    func setPost(_ post : FlamingoPost, highlightComment: Bool = true) {
        
        self.applyTheme(Theme.current)
        self.topInfoTopMarginConstraint.constant = (post.row == 0) ? 30 : 16
        
        if let subtitle = post.preview?.excerpt, !subtitle.isEmpty, subtitle != "null" {
            self.middleLabelTopMarginConstraint.constant = 10
            self.middleLabel.text = subtitle
        } else {
            self.middleLabelTopMarginConstraint.constant = 0
            self.middleLabel.text = ""
        }
                
        self.post = post
        self.alpha = post.isRead ? 0.3 : 1.0
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
    }
    
    func applyTheme(_ theme: Theme) {
        switch theme {
        case .day:
            self.topInfoLabel.backgroundColor = .black
            self.topInfoLabel.textColor = .white
            self.titleLabel.textColor = .black
            self.middleLabel.textColor = UIColor.init(white: 0, alpha: 0.5)
            self.contentView.backgroundColor = .white
            self.backgroundColor = .white
        case .night:
            self.topInfoLabel.backgroundColor = .white
            self.topInfoLabel.textColor = .black
            self.titleLabel.textColor = .white
            self.middleLabel.textColor = UIColor.init(white: 1, alpha: 0.5)
            self.contentView.backgroundColor = .black
            self.backgroundColor = .black
        }
    }
    
    // MARK: - Actions

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }
    
    @IBAction func selectComments() {
        guard let post = self.post else { return }
        self.delegate?.articleCell(self, didSelect: post)
    }
}
