//
//  String+HTML.swift
//  Flamingo
//
//  Native replacement for HTMLString pod - HTML entity decoding
//

import Foundation

extension String {
    
    /// Decodes HTML entities in the string (replacement for HTMLString's removingHTMLEntities)
    var removingHTMLEntities: String {
        guard self.contains("&") else { return self }
        
        var result = self
        
        // Named entities
        let namedEntities: [String: String] = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'",
            "&nbsp;": " ",
            "&ndash;": "–",
            "&mdash;": "—",
            "&lsquo;": "'",
            "&rsquo;": "'",
            "&ldquo;": "\u{201C}",
            "&rdquo;": "\u{201D}",
            "&hellip;": "…",
            "&copy;": "©",
            "&reg;": "®",
            "&trade;": "™",
            "&euro;": "€",
            "&pound;": "£",
            "&yen;": "¥",
            "&cent;": "¢",
            "&deg;": "°",
            "&plusmn;": "±",
            "&times;": "×",
            "&divide;": "÷",
            "&frac12;": "½",
            "&frac14;": "¼",
            "&frac34;": "¾",
            "&para;": "¶",
            "&sect;": "§",
            "&bull;": "•",
            "&middot;": "·",
            "&iexcl;": "¡",
            "&iquest;": "¿",
            "&laquo;": "«",
            "&raquo;": "»",
            "&acute;": "´",
            "&cedil;": "¸",
            "&macr;": "¯",
            "&uml;": "¨",
            "&ordf;": "ª",
            "&ordm;": "º",
            "&not;": "¬",
            "&shy;": "\u{00AD}",
            "&brvbar;": "¦",
            "&curren;": "¤"
        ]
        
        for (entity, character) in namedEntities {
            result = result.replacingOccurrences(of: entity, with: character)
        }
        
        // Decimal numeric entities (&#123;)
        if let regex = try? NSRegularExpression(pattern: "&#(\\d+);", options: []) {
            let nsString = result as NSString
            let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                let codeRange = match.range(at: 1)
                let codeString = nsString.substring(with: codeRange)
                if let code = Int(codeString), let scalar = Unicode.Scalar(code) {
                    let character = String(Character(scalar))
                    result = (result as NSString).replacingCharacters(in: match.range, with: character)
                }
            }
        }
        
        // Hexadecimal numeric entities (&#x1F4A9; or &#X1F4A9;)
        if let regex = try? NSRegularExpression(pattern: "&#[xX]([0-9a-fA-F]+);", options: []) {
            let nsString = result as NSString
            let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                let codeRange = match.range(at: 1)
                let codeString = nsString.substring(with: codeRange)
                if let code = Int(codeString, radix: 16), let scalar = Unicode.Scalar(code) {
                    let character = String(Character(scalar))
                    result = (result as NSString).replacingCharacters(in: match.range, with: character)
                }
            }
        }
        
        return result
    }
}
