//
//  MainTabController.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 05/06/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

class MainTabController : UITabBarController {
    
    lazy var topController: ArticleListVC = {
        let controller = R.storyboard.articleList.articleListVC()!
        controller.pageType = .front
        let item = UITabBarItem(title: "Top",
                                image: FontIcon(.star, size: 24, color: UIColor.darkGray).image,
                                selectedImage: FontIcon(.star, size: 24, color: UIColor.orange).image)
        controller.tabBarItem = item
        
        return controller
    }()
    
    lazy var newsController: ArticleListVC = {
        let controller = R.storyboard.articleList.articleListVC()!
        controller.pageType = .news
        let item = UITabBarItem(title: "News",
                                image: FontIcon(.newspaper, size: 24, color: UIColor.darkGray).image,
                                selectedImage: FontIcon(.newspaper, size: 24, color: UIColor.orange).image)
        controller.tabBarItem = item
        
        return controller
    }()
    
    lazy var settingsController: SettingsVC = {
        let controller = R.storyboard.settingsVC.settingsVC()!
        let item = UITabBarItem(title: "Settings",
                                image: FontIcon(.settings, size: 24, color: UIColor.darkGray).image,
                                selectedImage: FontIcon(.settings, size: 24, color: UIColor.orange).image)
        controller.tabBarItem = item
        
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaultsAtts: [NSAttributedStringKey : Any] = [.foregroundColor: UIColor.darkGray]
        let selectedAtts: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor: UIColor.orange]
        UITabBarItem.appearance().setTitleTextAttributes(defaultsAtts, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAtts, for: .selected)
        
        self.viewControllers = [FlamingoNVC(rootViewController: topController),
                                FlamingoNVC(rootViewController: newsController),
                                FlamingoNVC(rootViewController: settingsController)]
    }
    
}
