//
//  Source.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 07/06/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation
import RealmSwift

class Source : Object {
        
    @objc dynamic var domain : String = ""
    @objc dynamic var allow : Bool = true
 
    override static func primaryKey() -> String? {
        return "domain"
    }
    
}
