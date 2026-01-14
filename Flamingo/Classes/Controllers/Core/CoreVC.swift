//
//  CoreVC.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 22/07/2019.
//  Copyright © 2019 alexiscreuzot. All rights reserved.
//

import UIKit

enum NavigationBarType {
    case clear
    case solid(UIColor)
}

class CoreVC: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    enum ExitButtonSide {
        case left
        case right
    }
    
    var willDismissBlock: (() -> Void)?
    var isDismissable = true {
        didSet {
            if isViewLoaded {
                refreshUI()
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.presentationController?.delegate = self
        presentationController?.delegate = self
        refreshUI()
    }
    
    func setNavigationBar(type: NavigationBarType) {
        switch type {
        case .clear:
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
        case .solid(let color):
            navigationController?.navigationBar.setBackgroundImage(color.image(), for: .default)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willDismissBlock?()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
        guard modalPresentationStyle != .fullScreen else { return }
        if let nav = navigationController, nav.modalPresentationStyle == .fullScreen { return }
    }
    
    // MARK: - Private
    
    private func refreshUI() {
        let hasPreviousControllers = (navigationController?.viewControllers.count ?? 0) > 1
        let isPresented = isBeingPresented || (navigationController?.isBeingPresented ?? false)
        
        if isDismissable && isPresented && !hasPreviousControllers {
            addExitButton(side: .right)
        } else {
            isModalInPresentation = true
        }
    }
    
    func addExitButton(side: ExitButtonSide) {
        let exitButton = UIBarButtonItem(
            image: MaterialIcon.clear.imageFor(size: 24, color: CustomColor.primary),
            style: .plain,
            target: self,
            action: #selector(dismissController)
        )
        exitButton.tintColor = CustomColor.primary
        exitButton.accessibilityIdentifier = "close"
        
        switch side {
        case .left:
            navigationItem.setLeftBarButton(exitButton, animated: false)
        case .right:
            navigationItem.setRightBarButton(exitButton, animated: false)
        }
    }
    
    @IBAction func dismissController() {
        if presentingViewController != nil {
            presentingViewController?.viewWillAppear(true)
            dismiss(animated: true)
        } else {
            navigationController?.viewControllers.first?.viewWillAppear(true)
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - UIAdaptivePresentationControllerDelegate
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        presentationController.presentingViewController.viewWillAppear(true)
    }
}
