//
//  LinkLabel.swift
//  Flamingo
//
//  Native replacement for TTTAttributedLabel - UILabel with clickable links
//

import UIKit

protocol LinkLabelDelegate: AnyObject {
    func linkLabel(_ label: LinkLabel, didSelectLinkWith url: URL)
}

class LinkLabel: UILabel {
    
    weak var delegate: LinkLabelDelegate?
    
    var linkAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.systemBlue,
        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    var enabledTextCheckingTypes: NSTextCheckingResult.CheckingType = .link
    
    private var linkRanges: [(range: NSRange, url: URL)] = []
    private var textStorage: NSTextStorage?
    private var layoutManager: NSLayoutManager?
    private var textContainer: NSTextContainer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }
    
    func setText(_ attributedText: NSAttributedString) {
        // Detect links in the attributed string
        linkRanges.removeAll()
        
        let mutableText = NSMutableAttributedString(attributedString: attributedText)
        
        // Find existing links in attributes
        attributedText.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedText.length)) { value, range, _ in
            if let url = value as? URL {
                linkRanges.append((range, url))
                mutableText.addAttributes(linkAttributes, range: range)
            } else if let urlString = value as? String, let url = URL(string: urlString) {
                linkRanges.append((range, url))
                mutableText.addAttributes(linkAttributes, range: range)
            }
        }
        
        // Auto-detect URLs if enabled
        if enabledTextCheckingTypes.contains(.link) {
            let text = attributedText.string
            if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
                let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
                for match in matches {
                    if let url = match.url {
                        // Check if this range is already a link
                        let alreadyLinked = linkRanges.contains { NSIntersectionRange($0.range, match.range).length > 0 }
                        if !alreadyLinked {
                            linkRanges.append((match.range, url))
                            mutableText.addAttributes(linkAttributes, range: match.range)
                        }
                    }
                }
            }
        }
        
        self.attributedText = mutableText
        
        // Set up text kit for hit testing
        setupTextKit(with: mutableText)
    }
    
    private func setupTextKit(with attributedText: NSAttributedString) {
        textStorage = NSTextStorage(attributedString: attributedText)
        layoutManager = NSLayoutManager()
        textContainer = NSTextContainer(size: .zero)
        
        textContainer?.lineFragmentPadding = 0
        textContainer?.lineBreakMode = lineBreakMode
        textContainer?.maximumNumberOfLines = numberOfLines
        
        layoutManager?.addTextContainer(textContainer!)
        textStorage?.addLayoutManager(layoutManager!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textContainer?.size = bounds.size
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let _ = attributedText,
              let textContainer = textContainer,
              let layoutManager = layoutManager else {
            return
        }
        
        // Update text container size
        textContainer.size = bounds.size
        
        let locationOfTouch = gesture.location(in: self)
        
        // Calculate text bounds
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        // Adjust for alignment
        var textOffset = CGPoint.zero
        switch textAlignment {
        case .center:
            textOffset.x = (bounds.width - textBoundingBox.width) / 2
        case .right:
            textOffset.x = bounds.width - textBoundingBox.width
        default:
            break
        }
        
        // Vertical centering
        textOffset.y = (bounds.height - textBoundingBox.height) / 2
        
        let adjustedLocation = CGPoint(
            x: locationOfTouch.x - textOffset.x - textBoundingBox.origin.x,
            y: locationOfTouch.y - textOffset.y - textBoundingBox.origin.y
        )
        
        guard adjustedLocation.x >= 0 && adjustedLocation.y >= 0 else { return }
        
        let characterIndex = layoutManager.characterIndex(
            for: adjustedLocation,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // Check if the tapped character is within a link range
        for (range, url) in linkRanges {
            if NSLocationInRange(characterIndex, range) {
                delegate?.linkLabel(self, didSelectLinkWith: url)
                return
            }
        }
    }
}
