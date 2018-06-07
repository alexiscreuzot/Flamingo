//
//  FontIcon
//

import UIKit


enum Icon: String {
    case star = "\u{e903}"
    case newspaper = "\u{e900}"
    case settings = "\u{e901}"
    case commentBubble = "\u{e904}"
    case clock = "\u{e902}"
}

class FontIcon {

    public static var FontName = "flamingo"
	var code: String
	var pointSize: CGFloat = 10
	var color: UIColor = UIColor.black
    var alignment: NSTextAlignment = .left
    
    public static func fontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: FontIcon.FontName, size: size)!
    }

    init(_ code: Icon, size: CGFloat = 10, color: UIColor = .black) {
		self.code = code.rawValue
        self.pointSize = size
        self.color = color
	}

    var attributes : [NSAttributedStringKey : Any] {
  
        let iconParagraphStyle = NSMutableParagraphStyle()
        iconParagraphStyle.alignment = self.alignment
        return [
            .font: UIFont(name: FontIcon.FontName, size: self.pointSize)!,
            .foregroundColor: self.color,
            .paragraphStyle : iconParagraphStyle
        ]
    }

    var attributedString : NSAttributedString {
		return NSAttributedString(string: self.code, attributes: self.attributes)
	}

    var mutableAttributedString : NSMutableAttributedString {
		return self.attributedString.mutableCopy() as! NSMutableAttributedString
	}

    var image : UIImage {
        let size = CGSize(width: self.pointSize, height : self.pointSize)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.code.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), withAttributes: self.attributes)
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image.withRenderingMode(.alwaysOriginal)
	}
}
