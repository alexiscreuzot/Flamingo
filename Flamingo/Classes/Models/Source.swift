//
//  Source.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 07/06/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Source : Object, Decodable{
    
    @objc dynamic var domain : String = ""
    @objc dynamic var activated : Bool = false
    
    private enum SourceCodingKeys: String, CodingKey {
        case activated
        case domain
    }
    
    public static func isAllowed(domain: String) -> Bool{
        if  let realm = try? Realm(),
            let source = realm.objects(Source.self).first(where: {$0.domain == domain}) {
                return source.activated
        }
        return true
    }
    
    // Required inits
    
    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    // Convenience inits
    
    convenience init(domain: String, activated: Bool) {
        self.init()
         self.activated = activated
        self.domain = domain
       
    }
    
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SourceCodingKeys.self)
        let activated = try container.decode(Bool.self, forKey: .activated)
        let domain = try container.decode(String.self, forKey: .domain)
        
        self.init(domain: domain, activated: activated)
    }
    
    // private methods
 
    
    override static func primaryKey() -> String? {
        return "domain"
    }
    
    func toDict() -> [String : Any] {
        return ["activated" : activated,
                "domain" : domain]
    }
    
    func toJSON() -> String {
        let dict = self.toDict()
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]),
            let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            return ""
        }
    }
    
}

class Sources {
    static func toJSON() -> String {
        if  let sources = try? Array(Realm().objects(Source.self)),
            let jsonData = try? JSONSerialization.data(withJSONObject: sources.map {$0.toDict()}, options: [.prettyPrinted]),
            let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            return ""
        }
    }
}
