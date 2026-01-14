//
//  AttributedMarkup.swift
//  Flamingo
//
//  Native replacement for Attributed pod - HTML to NSAttributedString conversion
//

import UIKit

// MARK: - Modifier Protocol

struct AttributeModifier {
    let tag: String
    let attributes: [NSAttributedString.Key: Any]
}

func modifierWithBaseAttributes(
    _ baseAttributes: [NSAttributedString.Key: Any],
    modifiers: [AttributeModifier]
) -> MarkupModifier {
    return MarkupModifier(baseAttributes: baseAttributes, tagModifiers: modifiers)
}

struct MarkupModifier {
    let baseAttributes: [NSAttributedString.Key: Any]
    let tagModifiers: [AttributeModifier]
}

// MARK: - NSAttributedString Extension

extension NSAttributedString {
    
    /// Converts HTML markup to NSAttributedString (replacement for Attributed pod)
    static func attributedStringFromMarkup(_ markup: String, withModifier modifier: MarkupModifier) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        // Simple HTML tag processing
        let tagPattern = "<(/?)(\\w+)([^>]*)>"
        
        guard let regex = try? NSRegularExpression(pattern: tagPattern, options: []) else {
            return NSAttributedString(string: markup.removingHTMLEntities, attributes: modifier.baseAttributes)
        }
        
        var lastIndex = markup.startIndex
        var attributeStack: [[NSAttributedString.Key: Any]] = [modifier.baseAttributes]
        var tagStack: [String] = []
        
        let nsString = markup as NSString
        let matches = regex.matches(in: markup, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            let matchRange = match.range
            let isClosing = nsString.substring(with: match.range(at: 1)) == "/"
            let tagName = nsString.substring(with: match.range(at: 2)).lowercased()
            let tagAttributes = match.range(at: 3).length > 0 ? nsString.substring(with: match.range(at: 3)) : ""
            
            // Add text before this tag
            let startIndex = markup.index(markup.startIndex, offsetBy: lastIndex.utf16Offset(in: markup))
            let endIndex = markup.index(markup.startIndex, offsetBy: matchRange.location)
            
            if startIndex < endIndex {
                let textBefore = String(markup[startIndex..<endIndex])
                let decodedText = textBefore.removingHTMLEntities
                let currentAttrs = attributeStack.last ?? modifier.baseAttributes
                result.append(NSAttributedString(string: decodedText, attributes: currentAttrs))
            }
            
            // Update index
            lastIndex = markup.index(markup.startIndex, offsetBy: matchRange.location + matchRange.length)
            
            if isClosing {
                // Pop attributes if matching tag
                if let lastTag = tagStack.last, lastTag == tagName {
                    tagStack.removeLast()
                    if attributeStack.count > 1 {
                        attributeStack.removeLast()
                    }
                }
            } else {
                // Push new attributes based on tag
                var newAttributes = attributeStack.last ?? modifier.baseAttributes
                
                switch tagName {
                case "b", "strong":
                    if let font = newAttributes[.font] as? UIFont {
                        newAttributes[.font] = UIFont.boldSystemFont(ofSize: font.pointSize)
                    }
                case "i", "em":
                    if let font = newAttributes[.font] as? UIFont {
                        newAttributes[.font] = UIFont.italicSystemFont(ofSize: font.pointSize)
                    }
                case "u":
                    newAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                case "s", "strike", "del":
                    newAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
                case "code", "pre":
                    if let font = newAttributes[.font] as? UIFont {
                        newAttributes[.font] = UIFont(name: "Menlo", size: font.pointSize) ?? UIFont.monospacedSystemFont(ofSize: font.pointSize, weight: .regular)
                    }
                case "a":
                    // Extract href if present
                    if let hrefMatch = tagAttributes.range(of: "href=[\"']([^\"']+)[\"']", options: .regularExpression) {
                        let hrefValue = String(tagAttributes[hrefMatch])
                            .replacingOccurrences(of: "href=\"", with: "")
                            .replacingOccurrences(of: "href='", with: "")
                            .replacingOccurrences(of: "\"", with: "")
                            .replacingOccurrences(of: "'", with: "")
                        if let url = URL(string: hrefValue) {
                            newAttributes[.link] = url
                        }
                    }
                    newAttributes[.foregroundColor] = UIColor.systemBlue
                default:
                    // Check custom modifiers
                    if let customModifier = modifier.tagModifiers.first(where: { $0.tag == tagName }) {
                        newAttributes.merge(customModifier.attributes) { _, new in new }
                    }
                }
                
                tagStack.append(tagName)
                attributeStack.append(newAttributes)
            }
        }
        
        // Add remaining text
        if lastIndex < markup.endIndex {
            let remainingText = String(markup[lastIndex...])
            let decodedText = remainingText.removingHTMLEntities
            let currentAttrs = attributeStack.last ?? modifier.baseAttributes
            result.append(NSAttributedString(string: decodedText, attributes: currentAttrs))
        }
        
        return result
    }
}
