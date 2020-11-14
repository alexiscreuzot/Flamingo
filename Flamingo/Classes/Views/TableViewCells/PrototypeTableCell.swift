//
//  PrototypeTableCell.swift
//

import UIKit

protocol PrototypeTableCellProtocol {
    func setPrototypeContent(_ content: PrototypeTableCellContent)
}

class PrototypeTableCellContent: NSObject {
    var cellType: AnyClass
    var identifier: Int?
    var payload: Any?
    var height: CGFloat = 50
    var estimatedHeight: CGFloat = UITableView.automaticDimension
    var backgroundColor: UIColor = UIColor.clear

    var reuseIdentifier : String {
        get {
            return String(describing: cellType)
        }
    }

    init(_ type: AnyClass) {
        self.cellType = type
    }
}

class PrototypeTableCell : UITableViewCell, PrototypeTableCellProtocol {
    
    var cellContent = PrototypeTableCellContent(UITableViewCell.self)

    func setPrototypeContent(_ content: PrototypeTableCellContent) {
        self.cellContent = content
        self.backgroundColor = self.cellContent.backgroundColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selView = UIView()
        selView.backgroundColor = UIColor.label.withAlphaComponent(0.05)
        self.selectedBackgroundView = selView
        
        self.selectionStyle = .none
    }
}
