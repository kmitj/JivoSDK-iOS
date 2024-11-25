//
//  JMMarkdownImageElement.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 15/12/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit
import UIKit

public final class JMMarkdownImageElement: CDMarkdownLinkElement {
    fileprivate static let regex = "\\[img\\]([^\\)]+?)\\[/img\\]"

    public var font: UIFont?
    public var color: UIColor?
    public var backgroundColor: UIColor?
    public var paragraphStyle: NSParagraphStyle?
    public var maximumWidth: CGFloat?
    public var sizing = JMMarkdownImageAttachmentSizing.scaleToFit

    public var regex: String {
        return JMMarkdownImageElement.regex
    }
    
    public func regularExpression() throws -> NSRegularExpression {
        let regexp = try NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
        return regexp
    }
    
    init(font: UIFont? = nil, color: UIColor? = UIColor.blue, backgroundColor: UIColor? = nil) {
        self.font = font
        self.color = color
        self.backgroundColor = backgroundColor
    }
    
    public func formatText(_ attributedString: NSMutableAttributedString, range: NSRange,
                         link: String) {
    }
    
    public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        let nameRange = match.range(at: 1)
        let name = (attributedString.string as NSString).substring(with: nameRange)
        let attributes = attributedString.attributes(at: nameRange.location, effectiveRange: nil)
        
        let image = UIImage(named: name)
        
        if let image = image, let font = attributes[.font] as? UIFont {
            let textAttachment = JMMarkdownImageAttachment(font: font, image: image, sizing: sizing)
            let textAttachmentAttributedString = NSAttributedString(attachment: textAttachment)
            attributedString.replaceCharacters(in: match.range, with: textAttachmentAttributedString)
        }
    }
    
    public func addAttributes(_ attributedString: NSMutableAttributedString, range: NSRange,
                            link: String) {
    }
    
    private func scaledSize(image: UIImage) -> CGSize {
        guard let maximumWidth = maximumWidth else { return image.size }
        guard maximumWidth < image.size.width else { return image.size }
        
        let scale = image.size.width / maximumWidth
        return CGSize(width: image.size.width / scale, height: image.size.height / scale)
    }
}
