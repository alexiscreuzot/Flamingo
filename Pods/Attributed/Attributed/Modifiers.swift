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

public enum Modifiers {
    public static func regular(_ attributedString: NSAttributedString) -> NSAttributedString {
        guard attributedString.length > 0,
            let result = attributedString.mutableCopy() as? NSMutableAttributedString else { return attributedString }

        if let font = attributedString.attributes(at: 0, effectiveRange: nil)[.font] as? UIFont {
            let range = NSMakeRange(0, attributedString.length)
            result.addAttribute(.font, value: font.fontWithRegular(), range: range)
        }
        return result
    }

    public static func bold(_ attributedString: NSAttributedString) -> NSAttributedString {
        guard attributedString.length > 0,
            let result = attributedString.mutableCopy() as? NSMutableAttributedString else { return attributedString }

        if let font = attributedString.attributes(at: 0, effectiveRange: nil)[.font] as? UIFont {
            let range = NSMakeRange(0, attributedString.length)
            result.addAttribute(.font, value: font.fontWithBold(), range: range)
        }
        return result
    }

    public static func italic(_ attributedString: NSAttributedString) -> NSAttributedString {
        guard attributedString.length > 0,
            let result = attributedString.mutableCopy() as? NSMutableAttributedString else { return attributedString }

        if let font = attributedString.attributes(at: 0, effectiveRange: nil)[.font] as? UIFont {
            let range = NSMakeRange(0, attributedString.length)
            result.addAttribute(.font, value: font.fontWithItalic(), range: range)
        }
        return result
    }

    public static func monospacedNumbers(_ attributedString: NSAttributedString) -> NSAttributedString {
        guard attributedString.length > 0,
            let result = attributedString.mutableCopy() as? NSMutableAttributedString else { return attributedString }

        if let font = attributedString.attributes(at: 0, effectiveRange: nil)[.font] as? UIFont {
            let range = NSMakeRange(0, attributedString.length)
            result.addAttribute(.font, value: font.fontWithMonospacedNumbers(), range: range)
        }
        return result
    }

    public static func smallCaps(_ attributedString: NSAttributedString) -> NSAttributedString {
        guard attributedString.length > 0,
            let result = attributedString.mutableCopy() as? NSMutableAttributedString else { return attributedString }

        let attributes = attributedString.attributes(at: 0, effectiveRange: nil)
        if let font = attributes[.font] as? UIFont {
            let range = NSMakeRange(0, attributedString.length)
            if font.supportsSmallCaps, let smallCapsFont = font.fontWithSmallCaps() {
                result.addAttribute(.font, value: smallCapsFont, range: range)
            } else {
                result.simulateSmallCapsInRange(range, withFont: font, attributes: attributes)
            }
        }
        return result
    }

    public static func para(_ context: NSAttributedString, _ attributedString: NSAttributedString) -> NSAttributedString {
        guard let result = attributedString.mutableCopy() as? NSMutableAttributedString else { return attributedString }

        result.insert(NSAttributedString(string: "\n", attributes: context.attributes(at: context.length - 1, effectiveRange: nil)), at: attributedString.length)
        return result
    }

    public static func lineBreak(_ context: NSAttributedString, attributedString: NSAttributedString) -> NSAttributedString {
        return NSAttributedString(string: "\n", attributes: context.attributes(at: context.length - 1, effectiveRange: nil))
    }

    public static func link(urlAttributeName: String = "href") -> MapWithElement {
        return { element, attributedString in
            guard attributedString.length > 0,
                let result = attributedString.mutableCopy() as? NSMutableAttributedString,
                let href = element.attributes[urlAttributeName],
                let url = URL(string: href) else { return attributedString }

            let range = NSMakeRange(0, attributedString.length)
            result.addAttribute(.link, value: url, range: range)
            return result
        }
    }
}

private let widontRegex = try! NSRegularExpression(pattern: "\\S(\\s+)\\S+\\s*$", options: .anchorsMatchLines)

extension Modifiers {
    public static func widont(_ attributedString: NSAttributedString) -> NSAttributedString {
        guard let result = attributedString.mutableCopy() as? NSMutableAttributedString else { return attributedString }

        let string = result.string
        for match in widontRegex.matches(in: string, range: NSRange(location: 0, length: string.utf16.count)).reversed() {
            result.replaceCharacters(in: match.range(at: 1), with: "\u{00a0}")
        }
        return result
    }
}
