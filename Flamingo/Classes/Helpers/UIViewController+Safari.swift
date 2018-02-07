//
//  UIViewController+Safari.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 07/02/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit
import SafariServices


extension UIViewController : SFSafariViewControllerDelegate{
    
    @objc func showURL(_ url: URL?) {
        if let url = url {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            config.barCollapsingEnabled = true
            let vc = SFSafariViewController(url: url, configuration: config)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - SFSafariViewControllerDelegate
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
