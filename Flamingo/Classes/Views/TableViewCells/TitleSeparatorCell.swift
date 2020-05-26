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
    
    init(title : String = "", alignment:NSTextAlignment = .left, backgroundColor: UIColor = UIColor.clear ) {
        self.title = title
        self.alignment = alignment
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

            if let attTitle = content.attributedTitle {
                titleLabel?.attributedText = attTitle
            } else {
                titleLabel?.text = content.title
            }
            
            titleLabel?.textAlignment = content.alignment
        }
    }
}
