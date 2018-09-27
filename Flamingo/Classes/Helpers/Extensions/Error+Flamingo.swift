//
//  Erro+Flamingo.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 27/09/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation

enum FlamingoError {
    case sourcesNotConfigured
    case nothingToShow
}

extension FlamingoError {
    
    var code : Int {
        switch self {
        case .sourcesNotConfigured:
            return 1001
        case .nothingToShow:
            return 1001
        }
    }
    
    var message : String {
        switch self {
        case .sourcesNotConfigured:
            return "You first need to configure the sources"
        case .nothingToShow:
            return "Nothing to show"
        }
    }
    
    var error : Error {
        return NSError(self) as Error
    }
    
}

extension NSError {
    
    convenience init(_ type: FlamingoError) {
        let bundleID = Bundle.main.bundleIdentifier ?? "unknown"
        self.init(domain: bundleID,
                  code: type.code,
                  userInfo: [NSLocalizedDescriptionKey : type.message])
        
    }
    
}
