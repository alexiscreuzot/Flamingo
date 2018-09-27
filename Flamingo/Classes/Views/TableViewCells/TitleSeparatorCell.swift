//
//  TitleSeparatorCell.swift
//  pilotv2
//
//  Created by Alexis Creuzot on 14/06/2017.
//  Copyright © 2017 waverlylabs. All rights reserved.
//

import Foundation
import UIKit

class TitleSeparatorCellContent: PrototypeTableCellContent {
    
    var attributedTitle: NSAttributedString?
    var title: String = ""
    var alignment: NSTextAlignment
    var color: UIColor
    
    init(title : String = "", alignment:NSTextAlignment = .left, color: UIColor = UIColor.black, backgroundColor: UIColor = UIColor.clear ) {
        self.title = title
        self.alignment = alignment
        self.color = color
        super.init(TitleSeparatorCell.self)
        self.backgroundColor = backgroundColor
        self.height =  UITableView.automaticDimension
    }
}

class TitleSeparatorCell: PrototypeTableCell {
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.clear
    }
    
    override func setPrototypeContent(_ content: PrototypeTableCellContent) {
        super.setPrototypeContent(content)
        if let content = content as? TitleSeparatorCellContent {
            self.backgroundColor = content.backgroundColor
            
            if let attTitle = content.attributedTitle {
                titleLabel?.attributedText = attTitle
            } else {
                titleLabel?.text = content.title
            }
            
            titleLabel?.textAlignment = content.alignment
            if  content.attributedTitle == nil {
                titleLabel?.textColor = content.color
            }
            
        }
    }
}
