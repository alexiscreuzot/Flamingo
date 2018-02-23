//
//  FluidController
//  Flamingo
//
//  Created by Alexis Creuzot on 19/02/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

class FluidController : UIViewController, UITableViewDelegate {
    
    var cellHeights = [IndexPath : CGFloat]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeights[indexPath] ?? 999
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeights[indexPath] = cell.bounds.height
    }
    
}
