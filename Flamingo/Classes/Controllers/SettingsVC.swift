//
//  SettingsVC.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 07/06/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit
import RealmSwift

enum SettingsCellIdentifier : SimpleCellIdentifier {
    case themeIdentifier
}

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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(themeDidChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)

        
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
        
        let currentThemeCell = SimpleTableCellContent.init(title: "Theme",
                                                           value: Theme.current.name,
                                                           accessoryType: .none,
                                                           identifier: SettingsCellIdentifier.themeIdentifier.rawValue)
        currentThemeCell.backgroundColor = Theme.current.style.backgroundColor
        currentThemeCell.titleColor = Theme.current.style.textColor
        currentThemeCell.valueColor = Theme.current.style.secondaryTextColor
        self.datasource.append(currentThemeCell)
        
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
        let titleAttributes: [NSAttributedString.Key : Any] = [.font : UIFont.preferredFont(forTextStyle: .headline),
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = self.datasource[indexPath.row]
        switch content.identifier {
        case SettingsCellIdentifier.themeIdentifier.rawValue:
            self.selectTheme()
        default:
            break
        }
    }
}

extension SettingsVC : Themable {
    
    func selectTheme() {
        let choiceSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        for theme in Theme.allCases {
            let action = UIAlertAction.init(title: theme.name, style: .default) { _ in
                Theme.current = theme
            }
            let isSelectedTheme = (Theme.current == theme)
            action.setValue(isSelectedTheme, forKey: "checked")
            choiceSheet.addAction(action)
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel)
        choiceSheet.addAction(cancelAction)
        self.present(choiceSheet, animated: true)
    }
    
    @objc func themeDidChange() {
        
        self.reloadData()
        
        self.view.backgroundColor = Theme.current.style.backgroundColor
        self.tableView.backgroundColor = Theme.current.style.backgroundColor
        self.tableView.separatorColor = Theme.current.style.secondaryBackgroundColor
    }
}
