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
    
    var title: String = ""
    var alignment: NSTextAlignment
    var color: UIColor
    var backgroundColor: UIColor
    
    init(title : String = "", alignment:NSTextAlignment = .left, color: UIColor = UIColor.black, backgroundColor: UIColor = UIColor.clear ) {
        self.title = title
        self.alignment = alignment
        self.color = color
        self.backgroundColor = backgroundColor
        super.init(TitleSeparatorCell.self)
        height = 48
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
            titleLabel?.text = content.title
            titleLabel?.textAlignment = content.alignment
            titleLabel?.textColor = content.color
        }
    }
}
