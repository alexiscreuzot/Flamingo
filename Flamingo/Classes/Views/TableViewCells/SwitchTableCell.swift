//
//  SwitchTableCell.swift
//  pilotv2
//
//  Created by Alexis Creuzot on 04/07/2017.
//  Copyright © 2017 waverlylabs. All rights reserved.
//

import UIKit

class SwitchTableCellContent: PrototypeTableCellContent {
    
    public typealias SwitchBlock = ((Bool) -> ())
    
    var title = ""
    var isOn = false
    var switchAction : SwitchBlock?
    var tint: UIColor = UIColor.orange
    
    convenience init(title: String, isOn : Bool, switchAction : SwitchBlock?) {
        self.init(SwitchTableCell.self)
        self.title = title
        self.isOn = isOn
        self.switchAction = switchAction
    }
}

class SwitchTableCell: PrototypeTableCell {
    
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var swithView : UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        swithView.addTarget(self, action: #selector(switchValueDidChange(sender:)), for: .valueChanged)
    }
    
    override func setPrototypeContent(_ content: PrototypeTableCellContent) {
        super.setPrototypeContent(content)
        if let content = content as? SwitchTableCellContent {
            self.titleLabel?.text = content.title
            self.swithView.setOn(content.isOn, animated: false)
            self.swithView.onTintColor = content.tint
        }
    }
    
    @objc func switchValueDidChange(sender: UISwitch!) {
        if let content = self.cellContent as? SwitchTableCellContent {
            content.isOn = sender.isOn
            content.switchAction?(sender.isOn)
        }
    }
    
}
