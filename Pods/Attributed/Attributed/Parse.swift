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

import UIKit

extension NSAttributedString {
    public static func attributedStringFromMarkup(_ markup: String, withModifier modifier: @escaping Modifier) -> NSAttributedString? {
        if let data = "<xml>\(markup)</xml>".data(using: .utf8) {
            let parser = XMLParser(data: data)
            let parserDelegate = ParserDelegate(modifier: modifier)
            parser.delegate = parserDelegate
            parser.parse()
            return parserDelegate.result
        } else {
            return nil
        }
    }
}

private class ParserDelegate: NSObject, XMLParserDelegate {
    let result = NSMutableAttributedString()
    
    let modifier: Modifier
    
    var lastIndex = 0
    var stack = [MarkupElement]()
    
    init(modifier: @escaping Modifier) {
        self.modifier = modifier
    }
    
    @objc
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        let range = NSMakeRange(lastIndex, result.length - lastIndex)
        modifyInRange(range)
        
        lastIndex = result.length
        stack.append(MarkupElement(name: elementName, attributes: attributeDict))
    }
    
    @objc
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let range = NSMakeRange(lastIndex, result.length - lastIndex)
        modifyInRange(range)
        
        lastIndex = result.length
        stack.removeLast()
    }
    
    @objc
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        result.append(NSAttributedString(string: string))
    }
    
    func modifyInRange(_ range: NSRange) {
        if !stack.isEmpty {
            modifier(result, range, Array(stack[1..<stack.count]))
        }
    }
}
