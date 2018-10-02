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
        
        self.tableView.estimatedRowHeight = 60
        
        self.reloadData()
    }
    
    func reloadData() {
        let sources = realm.objects(Source.self).sorted(byKeyPath: "domain")
        
        self.datasource = [PrototypeTableCellContent]()
        
        // Theme
        let themeTitle = TitleSeparatorCellContent(title: "\nTHEME",
                                                           alignment: .left,
                                                           color: .black,
                                                           backgroundColor: .init(white: 0, alpha: 0.02))
        self.datasource.append(themeTitle)
        let nightModeSwitch = SwitchTableCellContent(title: "Night Mode",
                                                      isOn: Theme.current == .night,
                                                      switchAction: { isOn in
                                                        
        })
        self.datasource.append(nightModeSwitch)
        
        // Sources
        let sourceTitleContent = TitleSeparatorCellContent(title: "\nSOURCES",
                                                                alignment: .left,
                                                                color: .black,
                                                                backgroundColor: .init(white: 0, alpha: 0.02))
        sourceTitleContent.height = UITableView.automaticDimension
        self.datasource.append(sourceTitleContent)
        
        
        let isOn = sources.reduce(true) { (res, source) -> Bool in
            return res && source.activated
        }
        let switchAllContent = SwitchTableCellContent(title: "ALL",
                                             isOn: isOn,
                                             switchAction: { isOn in
                                                LocalData.hasSetSources = true
                                                try! self.realm.write {
                                                    for source in sources {
                                                        source.activated = isOn
                                                    }
                                                }
                                                self.reloadData()
        })
        let titleAttributes: [NSAttributedString.Key : Any] = [.font : UIFont.boldSystemFont(ofSize: 16),
                                                               .foregroundColor : UIColor(white: 1.0, alpha: 1.0)]
        let switchAllString = NSMutableAttributedString.init(string: "ALL",
                                                       attributes: titleAttributes)
        switchAllContent.attributedTitle = switchAllString
        switchAllContent.tint = UIColor(hex: "58C6FA")
        switchAllContent.backgroundColor = UIColor(white: 0.05, alpha: 1.0)
        self.datasource.append(switchAllContent)
        
        let sourcesCells: [SwitchTableCellContent] = sources.map({ source in
            let content = SwitchTableCellContent(title: source.domain,
                                                 isOn: source.activated,
                                                 switchAction: { isOn in
                                                    LocalData.hasSetSources = true
                                                    try! self.realm.write {
                                                        source.activated = isOn
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
