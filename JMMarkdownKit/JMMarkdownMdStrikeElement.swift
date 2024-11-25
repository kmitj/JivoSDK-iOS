//
//  JMMarkdownMdStrikeElement.swift
//  JMMarkdown
//
//  Created by Stan Potemkin on 07.08.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit
import UIKit

public final class JMMarkdownMdStrikeElement: CDMarkdownElement, CDMarkdownStyle {
    fileprivate static let regex = "(~)(.+?)(~)"

    public var backgroundColor: UIColor?
    public var font: UIFont?
    public var color: UIColor?
    public var paragraphStyle: NSParagraphStyle?

    public func regularExpression() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
    }
    
    public var regex: String {
        return JMMarkdownMdStrikeElement.regex
    }
    
    public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        let textRange = match.range(at: 2)
        let text = attributedString.attributedSubstring(from: textRange)
        
        attributedString.replaceCharacters(in: match.range, with: text)
        attributedString.addAttributes(generateAttributes(), range: NSRange(location: match.range.lowerBound, length: text.length))
        attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: match.range.lowerBound, length: text.length))
    }
}
