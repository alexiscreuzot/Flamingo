//
//  JSONSerializer.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 27/09/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation
import RealmSwift

class JSONSerializer {
    static func serializeSources() {
        let jsonDecoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: R.file.sourcesJson()!)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard json is [AnyObject] else {
                assert(false, "failed to parse")
                return
            }
            do {
                let sources = try jsonDecoder.decode([Source].self, from: data)
                let realm = try! Realm()
                try! realm.write {
                    realm.add(sources)
                }
            } catch let error {
                print("failed to convert data : \(error)")
            }
        } catch let error {
            print(error)
        }
    }
}
