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

public typealias Modifier = (_ mutableAttributedString: NSMutableAttributedString, _ range: NSRange, _ stack: [MarkupElement]) -> Void

public func modifierWithBaseAttributes(_ attributes: [NSAttributedStringKey: Any], modifiers: [Modifier]) -> Modifier {
    return { mutableAttributedString, range, stack in
        mutableAttributedString.addAttributes(attributes, range: range)
        for modifier in modifiers {
            modifier(mutableAttributedString, range, stack)
        }
    }
}

public typealias Map = (NSAttributedString) -> NSAttributedString

public func selectMap(_ selector: String, _ map: @escaping Map) -> Modifier {
    return { mutableAttributedString, range, stack in
        for element in stack {
            if selector ~= element {
                let attributedString = mutableAttributedString.attributedSubstring(from: range)
                mutableAttributedString.replaceCharacters(in: range, with: map(attributedString))
            }
        }
    }
}

public typealias MapWithContext = (NSAttributedString, NSAttributedString) -> NSAttributedString

public func selectMap(_ selector: String, _ mapWithContext: @escaping MapWithContext) -> Modifier {
    return { mutableAttributedString, range, stack in
        for element in stack {
            if selector ~= element {
                let attributedString = mutableAttributedString.attributedSubstring(from: range)
                mutableAttributedString.replaceCharacters(in: range, with: mapWithContext(mutableAttributedString, attributedString))
            }
        }
    }
}

public func bold(_ attributedString: NSAttributedString) -> NSAttributedString {
    if let result = attributedString.mutableCopy() as? NSMutableAttributedString {
        if let font = attributedString.attributes(at: 0, effectiveRange: nil)[NSAttributedStringKey.font] as? UIFont {
            let range = NSMakeRange(0, attributedString.length)
            result.addAttribute(NSAttributedStringKey.font, value: font.fontWithBold(), range: range)
        }
        return result
    }
    return attributedString
}

public func italic(_ attributedString: NSAttributedString) -> NSAttributedString {
    if let result = attributedString.mutableCopy() as? NSMutableAttributedString {
        if let font = attributedString.attributes(at: 0, effectiveRange: nil)[NSAttributedStringKey.font] as? UIFont {
            let range = NSMakeRange(0, attributedString.length)
            result.addAttribute(NSAttributedStringKey.font, value: font.fontWithItalic(), range: range)
        }
        return result
    }
    return attributedString
}

public func monospacedNumbers(_ attributedString: NSAttributedString) -> NSAttributedString {
    if let result = attributedString.mutableCopy() as? NSMutableAttributedString {
        if let font = attributedString.attributes(at: 0, effectiveRange: nil)[NSAttributedStringKey.font] as? UIFont {
            let range = NSMakeRange(0, attributedString.length)
            result.addAttribute(NSAttributedStringKey.font, value: font.fontWithMonospacedNumbers(), range: range)
        }
        return result
    }
    return attributedString
}

public func smallCaps(_ attributedString: NSAttributedString) -> NSAttributedString {
    if let result = attributedString.mutableCopy() as? NSMutableAttributedString {
        let attributes = attributedString.attributes(at: 0, effectiveRange: nil)
        if let font = attributes[NSAttributedStringKey.font] as? UIFont {
            let range = NSMakeRange(0, attributedString.length)
            if font.supportsSmallCaps, let smallCapsFont = font.fontWithSmallCaps() {
                result.addAttribute(NSAttributedStringKey.font, value: smallCapsFont, range: range)
            } else {
                result.simulateSmallCapsInRange(range, withFont: font, attributes: attributes)
            }
        }
        return result
    }
    return attributedString
}

public func lineBreak(_ context: NSAttributedString, attributedString: NSAttributedString) -> NSAttributedString {
    return NSAttributedString(string: "\n", attributes: context.attributes(at: context.length - 1, effectiveRange: nil))
}
