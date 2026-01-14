//
//  Preview.swift
//  Flamingo
//
//  Created by Alex on 31/01/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation

class Preview {
    let title: String?
    let excerpt: String?
    let content: String?
    let author: String?
    let lead_image_url: String?
    let word_count: Int?
    
    init(data: ReadabilityData) {
        title = data.title
        excerpt = data.description
        content = data.text
        author = nil
        lead_image_url = data.topImage
        word_count = data.text?.count
    }
    
    var wordCount: Int? {
        if let word_count = word_count, word_count > 10 {
            return word_count
        } else if let computedWordCount = content?.tagless.wordCount {
            return computedWordCount
        } else {
            return nil
        }
    }

    var readTimeInMinutes: Int? {
        guard let wordCount = self.wordCount else {
            return nil
        }
        let rounded = (Float(wordCount) / 200.0).rounded()
        return max(Int(rounded), 1)
    }
}
