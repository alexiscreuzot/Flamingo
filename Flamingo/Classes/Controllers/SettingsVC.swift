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
        
        let sectionBackgroundColor = Theme.isNight
            ? UIColor.init(white: 0, alpha: 0.98)
            : UIColor.init(white: 0, alpha: 0.02)
        let cellBackgroundColor = Theme.isNight
            ? UIColor.black
            : UIColor.white
        let primaryTextColor = Theme.isNight
            ? UIColor.white
            : UIColor.black
         
        self.datasource = [PrototypeTableCellContent]()
        
        // Theme
        let themeTitle = TitleSeparatorCellContent(title: "\nTHEME",
                                                           alignment: .left,
                                                           color: primaryTextColor,
                                                           backgroundColor: sectionBackgroundColor)
        themeTitle.backgroundColor = sectionBackgroundColor
        self.datasource.append(themeTitle)
        let nightModeSwitch = SwitchTableCellContent(title: "Night Mode",
                                                      isOn: Theme.isNight,
                                                      switchAction: { isOn in
                                                        Theme.current = isOn ? .night : .day
        })
        nightModeSwitch.backgroundColor = cellBackgroundColor
        nightModeSwitch.titleColor = primaryTextColor
        self.datasource.append(nightModeSwitch)
        
        // Sources
        let sourceTitleContent = TitleSeparatorCellContent(title: "\nSOURCES",
                                                                alignment: .left,
                                                                color: primaryTextColor,
                                                                backgroundColor:sectionBackgroundColor)
        sourceTitleContent.height = UITableView.automaticDimension
        sourceTitleContent.backgroundColor = sectionBackgroundColor
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
                                                               .foregroundColor : primaryTextColor]
        let switchAllString = NSMutableAttributedString.init(string: "ALL",
                                                       attributes: titleAttributes)
        switchAllContent.attributedTitle = switchAllString
        switchAllContent.tint = UIColor(hex: "58C6FA")
        switchAllContent.backgroundColor = cellBackgroundColor
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
            content.backgroundColor = cellBackgroundColor
            content.titleColor = primaryTextColor
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
        
        self.tableView.separatorColor = Theme.isNight
            ? UIColor.white.withAlphaComponent(0.2)
            : UIColor.black.withAlphaComponent(0.2)
        self.view.backgroundColor = Theme.isNight ? .black : .white
        self.tableView.backgroundColor = Theme.isNight ? .black : .white
    }
}
