//
//  JMMarkdownHeaderElement.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 29/12/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit
import UIKit

public final class JMMarkdownHeaderElement: CDMarkdownElement, CDMarkdownStyle {
    fileprivate static let regex = "(\\[header\\])(.+?)\\[/header\\]"
    
    public var backgroundColor: UIColor?
    public var font: UIFont?
    public var color: UIColor?
    public var paragraphStyle: NSParagraphStyle?

    public func regularExpression() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
    }
    
    public var regex: String {
        return JMMarkdownHeaderElement.regex
    }
    
    public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        let textRange = match.range(at: 2)
        let text = attributedString.attributedSubstring(from: textRange)
        
        attributedString.replaceCharacters(in: match.range, with: text)
        attributedString.addAttributes(generateAttributes(), range: NSRange(location: 0, length: textRange.length))
    }
}
