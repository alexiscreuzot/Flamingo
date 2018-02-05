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

extension UIFont {
    func fontWithBold() -> UIFont {
        return fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits.union(.traitBold)).flatMap { UIFont(descriptor: $0, size: pointSize) } ?? self
    }
    
    func fontWithItalic() -> UIFont {
        return fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits.union(.traitItalic)).flatMap { UIFont(descriptor: $0, size: pointSize) } ?? self
    }
    
    func fontWithMonospacedNumbers() -> UIFont {
        #if os(watchOS)
            return UIFont.monospacedDigitSystemFont(ofSize: pointSize, weight: UIFont.Weight(rawValue: 0))
        #else
            if #available(iOS 9.0, *) {
                return UIFont.monospacedDigitSystemFont(ofSize: pointSize, weight: UIFont.Weight(rawValue: 0))
            } else {
                return UIFont(descriptor: fontDescriptor.addingAttributes([
                    UIFontDescriptor.AttributeName.featureSettings: [
                        [
                            UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                            UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector,
                        ],
                    ],
                ]), size: pointSize)
            }
        #endif
    }
    
    var supportsSmallCaps: Bool {
        #if os(iOS)
            for feature in CTFontCopyFeatures(self) as NSArray? as? [[String: AnyObject]] ?? [] where feature[kCTFontFeatureTypeIdentifierKey as String] as? Int == kLowerCaseType {
                for featureSelector in feature[kCTFontFeatureTypeSelectorsKey as String] as? [[String: AnyObject]] ?? [] where featureSelector[kCTFontFeatureSelectorIdentifierKey as String] as? Int == kLowerCaseSmallCapsSelector {
                    return true
                }
            }
        #endif
        
        return false
    }
    
    func fontWithSmallCaps() -> UIFont? {
        #if os(iOS)
            return UIFont(descriptor: fontDescriptor.addingAttributes([
                UIFontDescriptor.AttributeName.featureSettings: [
                    [
                        UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType,
                        UIFontDescriptor.FeatureKey.typeIdentifier: kLowerCaseSmallCapsSelector,
                    ],
                ],
            ]), size: pointSize)
        #else
            return nil
        #endif
    }
}
