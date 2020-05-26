# Attributed

[![Pod Version](https://img.shields.io/cocoapods/v/Attributed.svg)](Attributed.podspec)
[![Pod License](https://img.shields.io/cocoapods/l/Attributed.svg)](LICENSE)
[![Pod Platform](https://img.shields.io/cocoapods/p/Attributed.svg)](Attributed.podspec)
[![Build Status](https://img.shields.io/travis/CrossWaterBridge/Attributed.svg?branch=master)](https://travis-ci.org/CrossWaterBridge/Attributed)

Convert HTML or XML to an NSAttributedString.

### Installation

Install with CocoaPods by adding the following to your Podfile:

```ruby
use_frameworks!

pod 'Attributed'
```

Then run:

```bash
pod install
```

### Usage

```swift
import Attributed

let html = "Waltz, <em>bad nymph</em>, for quick jigs <span class=\"bold\">vex</span>."

let baseFont = UIFont.preferredFont(forTextStyle: .body)
let modifier = modifierWithBaseAttributes([.font: baseFont], modifiers: [
	selectMap("em", Modifiers.italic),
	selectMap("span.bold", Modifiers.bold),
])

let attributedString = NSAttributedString.attributedStringFromMarkup(html, withModifier: modifier)
```

### License

Attributed is released under the MIT license. See LICENSE for details.
