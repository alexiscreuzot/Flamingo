//
//  DeepPressPopupVC.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 15/05/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

class DeepPressPopupVC : UIViewController {
    
    typealias PopupAction = (() -> Void)
    
    @IBOutlet var overlayView : UIView!
    @IBOutlet var popupView : UIView!
    
    var onShare : PopupAction?
    var onOpenInSafari : PopupAction?
    
    var post : FlamingoPost?
    var position : CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popupView.clipsToBounds = true
        self.popupView.layer.cornerRadius = 10
        
        let touch = UITapGestureRecognizer(target: self, action: #selector(selectClose))
        self.overlayView.addGestureRecognizer(touch)
        
        
        self.popupView.transform = .init(scaleX: 0.8, y: 0.8)
        self.popupView.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let position = position {
            self.popupView.center = position
        }
        
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: .allowAnimatedContent, animations: {
                        self.popupView.transform = .identity
                        self.popupView.alpha = 1
        })
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: .allowAnimatedContent, animations: {
                        self.popupView.transform = .init(scaleX: 0.8, y: 0.8)
                        self.popupView.alpha = 0
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let position = position {
            self.popupView.center = position
        }
    }
    
    @IBAction func selectClose() {
        self.dismiss(animated: true)
    }
    
    @IBAction func selectOpenInSafari() {
        self.onShare?()
    }
    
    @IBAction func selectShare() {
        self.onOpenInSafari?()
    }
    
}
