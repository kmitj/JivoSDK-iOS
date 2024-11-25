//
//  JMMarkdownMdLinkElement.swift
//  JMMarkdown
//
//  Created by Stan Potemkin on 07.08.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit
import UIKit

public final class JMMarkdownMdLinkElement: CDMarkdownLinkElement {
    fileprivate static let regex = "\\[([^\\]]+?)\\]\\(([^\\)]+?)\\)"

    public var font: UIFont?
    public var color: UIColor?
    public var backgroundColor: UIColor?
    public var paragraphStyle: NSParagraphStyle?
    public var maxLength: Int?
    public var underlineStyle: NSUnderlineStyle?
    public var linksEnabled: Bool = true

    public var regex: String {
        return JMMarkdownMdLinkElement.regex
    }
    
    public func regularExpression() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
    }
    
    init(font: UIFont? = nil, color: UIColor? = UIColor.blue, backgroundColor: UIColor? = nil) {
        self.font = font
        self.color = color
        self.backgroundColor = backgroundColor
    }
    
    public func formatText(_ attributedString: NSMutableAttributedString, range: NSRange,
                         link: String) {
        guard linksEnabled else { return }
        guard let encodedLink = link.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let url = URL(string: link) ?? URL(string: encodedLink) else { return }
        attributedString.addAttribute(.link, value: url, range: range)
    }
    
    public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        let titleRange = match.range(at: 1)
        let title = (attributedString.string as NSString).substring(with: titleRange).clipBy(maxLength)
        
        let linkRange = match.range(at: 2)
        let link = (attributedString.string as NSString).substring(with: linkRange)
        
        let activeAttributes = attributedString.attributes(at: match.range.location, effectiveRange: nil)
        let replaceWithString = NSAttributedString(string: title, attributes: activeAttributes)
        attributedString.replaceCharacters(in: match.range, with: replaceWithString)
        
        let formatRange = NSRange(location: match.range.location, length: titleRange.length)
        formatText(attributedString, range: formatRange, link: link)
        addAttributes(attributedString, range: formatRange, link: link)
    }
    
    public func addAttributes(_ attributedString: NSMutableAttributedString, range: NSRange, link: String) {
        let shouldUnderline: Bool
        if underlineStyle == nil {
            shouldUnderline = false
        }
        else if underlineStyle == [] {
            shouldUnderline = false
        }
        else {
            shouldUnderline = true
        }
        
        var extendedAttributes = generateAttributes()
        extendedAttributes[.underlineStyle] = underlineStyle.flatMap { NSNumber(value: $0.rawValue) }
        extendedAttributes[.underlineColor] = shouldUnderline ? color : UIColor.clear
        attributedString.addAttributes(extendedAttributes, range: range)
    }
}
