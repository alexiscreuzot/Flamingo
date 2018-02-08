//
//  Extensions.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 30/01/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation

public func delay(_ seconds: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds, execute: closure)
}

extension String {
    var wordCount : Int {
        let words = self.components(separatedBy: .whitespacesAndNewlines)
        return words.count
    }
    
    var tagless : String {
        var words = self.components(separatedBy: .whitespacesAndNewlines)
        words = words.filter { string -> Bool in
            return !(string.contains("<") && (string.contains(">")))
        }
        return words.joined(separator: " ")
    }
    
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return
        }
    }
}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        precondition(indices.contains(from) && indices.contains(to), "invalid indexes")
        insert(remove(at: from), at: to)
    }
}
