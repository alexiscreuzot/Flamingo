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
        controller.title = "Top"
        controller.pageType = .front
        let item = UITabBarItem(title: nil,
                                image: FontIcon(.star, size: 24, color: UIColor.darkGray).image,
                                selectedImage: FontIcon(.star, size: 24, color: UIColor.orange).image)
        item.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        controller.tabBarItem = item
        
        return controller
    }()
    
    lazy var newsController: ArticleListVC = {
        let controller = R.storyboard.articleList.articleListVC()!
        controller.title = "News"
        controller.pageType = .news
        let item = UITabBarItem(title: nil,
                                image: FontIcon(.newspaper, size: 24, color: UIColor.darkGray).image,
                                selectedImage: FontIcon(.newspaper, size: 24, color: UIColor.orange).image)
        item.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        controller.tabBarItem = item
        
        return controller
    }()
    
    lazy var settingsController: SettingsVC = {
        let controller = R.storyboard.settingsVC.settingsVC()!
        controller.title = "Settings"
        let item = UITabBarItem(title: nil,
                                image: FontIcon(.settings, size: 24, color: UIColor.darkGray).image,
                                selectedImage: FontIcon(.settings, size: 24, color: UIColor.orange).image)
        item.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        controller.tabBarItem = item
        
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaultsAtts: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.black]
        let selectedAtts: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.orange]
        UITabBarItem.appearance().setTitleTextAttributes(defaultsAtts, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAtts, for: .selected)
        
        self.viewControllers = [FlamingoNVC(rootViewController: topController),
                                FlamingoNVC(rootViewController: newsController),
                                FlamingoNVC(rootViewController: settingsController)]
        
        self.delegate = self
    }
    
}

extension MainTabController : UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        
        guard   let currentController = selectedViewController,
            viewController != currentController else {
                
                self.scrollToTop(viewController)
                
                return false
        }
        
        let fromView = currentController.view!
        let toView = viewController.view!
        UIView.transition(from: fromView, to: toView, duration: 0.12, options: [.transitionCrossDissolve], completion: nil)
        
        return true
    }
    
    func scrollToTop(_ controller : UIViewController) {
        
        if let scrollView = controller.view.allSubViewsOf(type: UIScrollView.self).first {
            let topPoint = CGPoint.init(x: 0, y: -scrollView.contentInset.top)
            scrollView.setContentOffset(topPoint, animated: true)
        }
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let toView: UIView? = (viewController.tabBarItem.value(forKey: "view") as? UIView)
        toView?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: .allowUserInteraction, animations: {() -> Void in
            toView?.transform = CGAffineTransform.identity
        }, completion: { _ in })
        
        
    }
    
}
