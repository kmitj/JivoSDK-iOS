//
//  JMMarkdownCenterElement.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 28/12/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit
import UIKit

public final class JMMarkdownCenterElement: CDMarkdownElement {
    fileprivate static let regex = "\\[center\\]([^\\[]+?)\\[/center\\]"
    
    public var regex: String {
        return JMMarkdownCenterElement.regex
    }
    
    public func regularExpression() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
    }
    
    public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        let textRange = match.range(at: 1)
        let text = attributedString.attributedSubstring(from: textRange)
        
        attributedString.replaceCharacters(in: match.range, with: text)
        
        let formatRange = NSRange(location: match.range.location, length: textRange.length)
        addAttributes(attributedString, range: formatRange)
    }
    
    func addAttributes(_ attributedString: NSMutableAttributedString, range: NSRange) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        attributedString.addAttribute(.paragraphStyle, value: paragraph, range: range)
    }
}
