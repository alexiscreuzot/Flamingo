//
//  Error+Extensions.swift
//  coreml-FNS
//
//  Created by Alexis Creuzot on 30/03/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit

enum CustomError {
    case unknown
}

extension CustomError  : LocalizedError {
    
    public var errorDescription : String? {
        switch self {
        default:
            return  i18n.errorUnknown()
        }
    }
    
    public var nsError : NSError {
        return self as NSError
    }
    
}

extension Error {
    typealias AlertErrorCompletion = (() -> Void)
    
    func showAlertFrom(controller : UIViewController?,_ completion: AlertErrorCompletion? = nil) {
        
        guard let controller = controller else {
            return
        }
        
        let message = self.localizedDescription
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { _ in
            completion?()
        }
        alert.addAction(okAction)
        controller.present(alert, animated: true)
    }
}
