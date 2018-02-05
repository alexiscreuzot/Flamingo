//
// Copyright (c) 2015 Hilton Campbell
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

public struct MarkupElement {
    public let name: String
    public let attributes: [String: String]
    
    public init(name: String, attributes: [String: String]) {
        self.name = name
        self.attributes = attributes
    }
}

public func ~= (pattern: String, element: MarkupElement) -> Bool {
    let scanner = Scanner(string: pattern)
    scanner.charactersToBeSkipped = nil
    
    var name: NSString?
    if scanner.scanUpTo(".", into: &name), let name = name as String?, name == element.name {
        if scanner.scanString(".", into: nil) {
            var className: NSString?
            if scanner.scanUpTo("", into: &className), let className = className as String?, let elementClassName = element.attributes["class"], elementClassName == className {
                return true
            }
        } else {
            return true
        }
    }
    
    return false
}
