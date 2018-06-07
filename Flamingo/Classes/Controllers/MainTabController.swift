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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.darkGray],
                                                         for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.orange],
                                                         for: .selected)
        
        self.viewControllers = [FlamingoNVC(rootViewController: topController),
                                FlamingoNVC(rootViewController: newsController)]
        
        
        
    }
    
}
