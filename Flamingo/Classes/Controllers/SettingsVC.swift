//
//  SettingsVC.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 07/06/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsVC : UIViewController {
    
    @IBOutlet var tableView : UITableView!
    var datasource = [PrototypeTableCellContent]()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.largeTitleDisplayMode = .always
        
        self.reloadData()
    }
    
    func reloadData() {
        let sources = realm.objects(Source.self).sorted(byKeyPath: "domain")
        
        self.datasource = [PrototypeTableCellContent]()
        
        let sourceTitleContent = TitleSeparatorCellContent.init(title: "SOURCES",
                                                                alignment: .left,
                                                                color: .black,
                                                                backgroundColor: .init(white: 0, alpha: 0.05))
        sourceTitleContent.height = 80
        self.datasource.append(sourceTitleContent)
        
        let switchAllContent = SwitchTableCellContent(title: "All",
                                             isOn: UserDefaults.standard.unallowedDomains.isEmpty,
                                             switchAction: { isOn in
                                                if isOn{
                                                    UserDefaults.standard.unallowedDomains = [String]()
                                                } else {
                                                    UserDefaults.standard.unallowedDomains = sources.map { $0.domain }
                                                }
                                                self.reloadData()
        })
        switchAllContent.tint = UIColor.red
        self.datasource.append(switchAllContent)
        
        let sourcesCells: [SwitchTableCellContent] = sources.map({ source in
            let isBlocked = UserDefaults.standard.unallowedDomains.contains(source.domain)
            let content = SwitchTableCellContent(title: source.domain,
                                                 isOn: !isBlocked,
                                                 switchAction: { isOn in
                                                    if isOn{
                                                        source.allow()
                                                    } else {
                                                        source.block()
                                                    }
            })
            return content
        })
        self.datasource.append(contentsOf: sourcesCells)
        self.tableView.reloadData()
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
