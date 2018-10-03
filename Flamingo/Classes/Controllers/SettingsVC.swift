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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.current.style.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForThemeChange()
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
                                                           color: Theme.current.style.textColor,
                                                           backgroundColor: Theme.current.style.secondaryBackgroundColor)
        self.datasource.append(themeTitle)
        let nightModeSwitch = SwitchTableCellContent(title: "Night Mode",
                                                      isOn: Theme.isNight,
                                                      switchAction: { isOn in
                                                        Theme.current = isOn ? .night : .day
        })
        nightModeSwitch.backgroundColor = Theme.current.style.backgroundColor
        nightModeSwitch.titleColor = Theme.current.style.textColor
        nightModeSwitch.tint = Theme.current.style.accentColor
        self.datasource.append(nightModeSwitch)
        
        // Sources
        let sourceTitleContent = TitleSeparatorCellContent(title: "\nSOURCES",
                                                                alignment: .left,
                                                                color: Theme.current.style.textColor,
                                                                backgroundColor:Theme.current.style.secondaryBackgroundColor)
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
                                                               .foregroundColor : Theme.current.style.textColor]
        let switchAllString = NSMutableAttributedString.init(string: "ALL",
                                                       attributes: titleAttributes)
        switchAllContent.attributedTitle = switchAllString
        switchAllContent.tint = Theme.current.style.secondaryAccentColor
        switchAllContent.backgroundColor = Theme.current.style.backgroundColor
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
            content.backgroundColor = Theme.current.style.backgroundColor
            content.titleColor = Theme.current.style.textColor
            content.tint = Theme.current.style.accentColor
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

extension SettingsVC : Themable {
    func themeDidChange() {
        self.reloadData()
        self.view.backgroundColor = Theme.current.style.backgroundColor
        self.tableView.backgroundColor = Theme.current.style.backgroundColor
        self.tableView.separatorColor = Theme.current.style.secondaryBackgroundColor
    }
}
