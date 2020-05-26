//
//  AmbassadorViewController.swift
//  ambassador
//
//  Created by Alexis Creuzot on 22/07/2019.
//  Copyright © 2019 waverlylabs. All rights reserved.
//

import UIKit

enum NavigationBarType {
    case clear
    case solid(UIColor)
}

class CoreVC : UIViewController {
    
    typealias WillDismissBlock = (() -> Void)
    
    public enum ExitButtonSide {
        case left
        case right
    }
    
    public var debugTitle : String?
    public var willDismissBlock : WillDismissBlock?
    public var isDismissable = true {
        didSet {
            if self.isViewLoaded {
                self._refreshUI()
            }
        }
    }
    
    private let scrollGradientMaskLayer = CAGradientLayer()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.presentationController?.delegate = self
        self.presentationController?.delegate = self
        self._refreshUI()
    }
    
    func setNavigationBar(type: NavigationBarType) {
        switch type {
        case .clear:
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        case .solid(let color):
            self.navigationController?.navigationBar.setBackgroundImage(color.image(), for: .default)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent repeats
        if let _ = self.parent as? CoreVC {
            return
        }

        print(self.trailString)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.willDismissBlock?()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
        super.dismiss(animated: flag, completion: completion)
        
        guard self.modalPresentationStyle != .fullScreen else {
            return
        }
        
        if let nav = self.navigationController, nav.modalPresentationStyle == .fullScreen {
            return
        }
        
        if let presenter = self.presentingViewController {
            print(presenter.trailString)
        }
    }
    // MARK: - Public
    
    private func _refreshUI() {
        
        let hasPreviousControllers = self.navigationController?.viewControllers.count ?? 0 > 1
        let isPresented = isBeingPresented || (self.navigationController?.isBeingPresented ?? false)
        
        if isDismissable && isPresented && !hasPreviousControllers {
            self.addExitButton(side: .right)
        } else {
            if #available(iOS 13.0, *) {
                self.isModalInPresentation = true
            }
        }
    }
    
    func addExitButton(side: ExitButtonSide) {
                
        let exitButton  = UIBarButtonItem.init(image: MaterialIcon.clear.imageFor(size: 24, color: CustomColor.primary),
                                               style: .plain,
                                               target: self,
                                               action: #selector(dismissController))
        exitButton.tintColor = CustomColor.primary
        exitButton.accessibilityIdentifier = "close"
        switch side {
        case .left:
            self.navigationItem.setLeftBarButton(exitButton, animated: false)
            break
        case .right:
            self.navigationItem.setRightBarButton(exitButton, animated: false)
            break
        }
    }
    
    @IBAction func dismissController() {
        if let _ = self.presentingViewController {
            self.presentingViewController?.viewWillAppear(true)
            self.dismiss(animated: true)
        } else {
            self.navigationController?.viewControllers.first?.viewWillAppear(true)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

}

extension CoreVC : UIAdaptivePresentationControllerDelegate{
        
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        presentationController.presentingViewController.viewWillAppear(true)
    }
    
}


extension UIViewController {
    
    var trailString : String {
        let trail: [String] = self.trail
        let formattedTrail = trail.map { "[\($0)]"  }
        return formattedTrail.joined(separator: " > ")
    }
    
    var trail : [String] {
        var trail: [String] = []
                
        if let presenter = self.presentingViewController {
            trail += presenter.trail
        }
        if let nav = self as? UINavigationController {
            trail +=  nav.viewControllers[0].trail
        }
        if let nav = self.navigationController {
            for vc in nav.viewControllers {
                trail += [vc.name]
            }
        } else {
            trail += [self.name]
        }
        
        return trail.removeDuplicates()
    }
    
    var name : String {
        var string = String(describing:type(of:self))
        if let debuggableController = self as? CoreVC,
            let debugTitle = debuggableController.debugTitle {
            string += " - \(debugTitle)"
        }
        return string
    }
}
