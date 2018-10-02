//
//  SimpleTableCell.swift
//  pilotv2
//
//  Created by Alexis Creuzot on 18/07/2017.
//  Copyright © 2017 waverlylabs. All rights reserved.
//

import UIKit

typealias SimpleCellIdentifier = Int

class SimpleTableCellContent: PrototypeTableCellContent {
    
    var attributedTitle : NSAttributedString?
    var title : String!
    var value : String?
    var accessoryType: UITableViewCell.AccessoryType
    
    init(title: String, value : String? = nil, accessoryType : UITableViewCell.AccessoryType = .disclosureIndicator, identifier : SimpleCellIdentifier? = nil) {
        self.title = title
        self.value = value
        self.accessoryType = accessoryType
        super.init(SimpleTableCell.self)
        self.identifier = identifier
        self.height = UITableView.automaticDimension
    }
}

class SimpleTableCell: PrototypeTableCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setPrototypeContent(_ content: PrototypeTableCellContent) {
        super.setPrototypeContent(content)
        if let content = content as? SimpleTableCellContent {
            
            if let attributedTitle = content.attributedTitle {
                self.titleLabel.attributedText = attributedTitle
            } else {
               self.titleLabel.text = content.title
            }
            
            self.valueLabel.text = content.value
            
            self.accessoryType = content.accessoryType
            switch self.accessoryType {
            case .detailDisclosureButton,
                 .checkmark,
                 .disclosureIndicator :
                self.selectionStyle = .default
                break
            default:
                self.selectionStyle = .none
            }
            
        }
    }
}
