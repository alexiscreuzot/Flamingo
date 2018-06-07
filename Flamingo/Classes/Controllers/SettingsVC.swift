//
//  SettingsVC.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 07/06/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

class SettingsVC : UIViewController {
    
    @IBOutlet var tableView : UITableView!
    var datasource: [PrototypeTableCellContent] = [PrototypeTableCellContent]()
    var sources = Source.read()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.datasource = sources.map({ source in
            let content = SwitchTableCellContent(title: source.domain, isOn: source.allow, switchAction: nil)
            return content
        })
    }

}

extension SettingsVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let content = datasource[indexPath.row]
        return content.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = datasource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: content.reuseIdentifier, for: indexPath)
        if let cell = cell as? PrototypeTableCell {
            cell.setPrototypeContent(content)
        }
        return cell
    }
}
