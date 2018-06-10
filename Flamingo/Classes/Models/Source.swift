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
    
    convenience init(domain: String) {
        self.init()
        self.domain = domain
    }
 
    func allow() {
        var blacklist = UserDefaults.standard.unallowedDomains
        if let index = blacklist.index(of: self.domain){
            blacklist.remove(at: index)
        }
        UserDefaults.standard.unallowedDomains = blacklist
    }
    
    func block() {
        var blacklist = UserDefaults.standard.unallowedDomains
        if !blacklist.contains(self.domain) {
            blacklist.append(self.domain)
        }
        UserDefaults.standard.unallowedDomains = blacklist
    }
    
    override static func primaryKey() -> String? {
        return "domain"
    }
    
}
