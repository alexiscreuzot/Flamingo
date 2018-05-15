//
//  DeepPressPopupVC.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 15/05/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

class DeepPressPopupVC : UIViewController {
    
    @IBOutlet var overlayView : UIView!
    @IBOutlet var popupView : UIView!
    
    var post : FlamingoPost?
    var position : CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popupView.clipsToBounds = true
        self.popupView.layer.cornerRadius = 10
        
        let touch = UITapGestureRecognizer(target: self, action: #selector(selectClose))
        self.overlayView.addGestureRecognizer(touch)
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
        
        if let link = self.post?.hnPost.url {
            UIApplication.shared.open(link, options: [:], completionHandler: nil)
        }
        
        self.selectClose()
    }
    
    @IBAction func selectShare() {
        
        if let link = self.post?.hnPost.url {
            let activityVC = UIActivityViewController(activityItems: [link], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
        
        self.selectClose()
    }
    
}
