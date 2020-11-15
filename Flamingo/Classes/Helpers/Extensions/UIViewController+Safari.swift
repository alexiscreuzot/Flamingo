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
            self.tryAddingOverlay(to: vc)
        }
    }
    
    func tryAddingOverlay(to controller: SFSafariViewController) {
        if  let superview = controller.view, controller.children.first?.isViewLoaded ?? false {
            let overlay = UIView()
            overlay.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.92)
            superview.addSubview(overlay)
            overlay.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                overlay.topAnchor.constraint(equalTo: superview.layoutMarginsGuide.topAnchor, constant: 44),
                overlay.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                overlay.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                overlay.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
            ])
        } else {
            delay(0.02) { self.tryAddingOverlay(to: controller) }
        }
    }
    
    // MARK: - SFSafariViewControllerDelegate
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    public func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        
        guard let overlay = controller.view.subviews.last else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0.1) {
            overlay.alpha = 0
        } completion: { _ in
            overlay.removeFromSuperview()
        }
    }
}
