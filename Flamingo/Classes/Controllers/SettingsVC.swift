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
        return CustomPreferences.colorTheme.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.largeTitleDisplayMode = .always
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.backgroundColor = .secondarySystemBackground
                
        self.reloadData()
    }
    
    func reloadData() {
        let sources = realm.objects(Source.self).sorted(byKeyPath: "domain")
         
        self.datasource = [PrototypeTableCellContent]()
        
        // Theme
        let themeTitle = TitleSeparatorCellContent(title: "\nTHEME",
                                                           alignment: .left)
        self.datasource.append(themeTitle)
        
        let currentThemeCell = SimpleTableCellContent.init(title: "Theme",
                                                           value: CustomPreferences.colorTheme.localized,
                                                           accessoryType: .disclosureIndicator,
                                                           identifier: SettingsCellIdentifier.themeIdentifier.rawValue)
        self.datasource.append(currentThemeCell)
        
        // Sources
        let sourceTitleContent = TitleSeparatorCellContent(title: "\nSOURCES",
                                                                alignment: .left)
        sourceTitleContent.height = UITableView.automaticDimension
        self.datasource.append(sourceTitleContent)
        
        
        let isOn = sources.reduce(true) { (res, source) -> Bool in
            return res && source.activated
        }
        let switchAllContent = SwitchTableCellContent(title: "ALL",
                                             isOn: isOn,
                                             switchAction: { isOn in
                                                CustomPreferences.hasSetSources = true
                                                try! self.realm.write {
                                                    for source in sources {
                                                        source.activated = isOn
                                                    }
                                                }
                                                self.reloadData()
        })
        switchAllContent.tint = UIColor.systemGreen
        switchAllContent.title = "ALL"
        self.datasource.append(switchAllContent)
        
        let sourcesCells: [SwitchTableCellContent] = sources.map({ source in
            let content = SwitchTableCellContent(title: source.domain,
                                                 isOn: source.activated,
                                                 switchAction: { isOn in
                                                    CustomPreferences.hasSetSources = true
                                                    try! self.realm.write {
                                                        source.activated = isOn
                                                    }
                                                    
            })
            return content
        })
        self.datasource.append(contentsOf: sourcesCells)
        self.tableView.reloadData()
    }
    
    typealias SheetSelectBlock = ((Int) -> Void)
    func selectFrom(elements: [String], currentSelectedIndex: Int? = nil, completion: SheetSelectBlock? = nil) {
           let sheetView = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
           for (index, element) in elements.enumerated() {
               let action = UIAlertAction(title: element, style: .default) { _ in
                   completion?(index)
               }
               if index == currentSelectedIndex {
                   let image = MaterialIcon.check.imageFor(size: 20, color: UIColor.systemBlue)
                   action.setValue(image, forKey: "_image")
               }
               sheetView.addAction(action)
           }
           sheetView.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           self.present(sheetView, animated: true, completion: nil)
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
            let currentOption = Theme.allCases.firstIndex(of: CustomPreferences.colorTheme)
            self.selectFrom(elements: Theme.allCases.map {$0.localized},
                            currentSelectedIndex:currentOption) { selIndex in
                                CustomPreferences.colorTheme = Theme.allCases[selIndex]
                                ThemeService.shared.updateTheme()
            }
        default:
            break
        }
        delay(0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
