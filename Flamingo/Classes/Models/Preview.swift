//
//  Preview.swift
//  Flamingo
//
//  Created by Alex on 31/01/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation
import Mapper

class Preview: Mappable {
    let title: String
    let domain: String
    
    let excerpt: String?
    let content: String?
    let author: String?
    let lead_image_url: String?
    let word_count: Int?
    
    required init(map: Mapper) throws {
        try title = map.from("title")
        try domain = map.from("domain")
        excerpt = map.optionalFrom("excerpt")
        content =  map.optionalFrom("content")
        author = map.optionalFrom("author")
        lead_image_url = map.optionalFrom("lead_image_url")
        word_count = map.optionalFrom("word_count")
    }
    
    var wordCount : Int? {
        if let word_count = word_count, word_count > 10 {
            return word_count
        } else if let computedWordCount = content?.tagless.wordCount {
            return computedWordCount
        } else {
            return nil
        }
    }

    var readTimeInMinutes : Int? {
        guard let wordCount = self.wordCount else {
            return nil
        }
        let rounded = (Float(wordCount) / 200.0).rounded()
        return max(Int(rounded), 1)
    }
}
