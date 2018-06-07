//
//  Source.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 07/06/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation

struct Source : Codable, Equatable, Hashable {
        
    var domain : String
    var allow : Bool = true
    var hashValue: Int {
        return domain.hashValue
    }
    
    init(domain: String, allow: Bool = true) {
        self.domain = domain
        self.allow = allow
    }
    
    static func ==(lhs: Source, rhs: Source) -> Bool {
        return lhs.domain == rhs.domain
    }
    
    static func save(sourcesDomains: [String]) {
        let url = R.file.sourcesJson.url()!
        let existingSources = Set<Source>(Source.read())
        let newSources = Set<Source>(sourcesDomains.map { return Source(domain: $0) })
        let sourcesToSave = existingSources.union(newSources)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(sourcesToSave)
            try data.write(to: url, options: [])
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func read() -> [Source] {
        let url = R.file.sourcesJson.url()!
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: url, options: [])
            let posts = try decoder.decode([Source].self, from: data)
            return posts
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
