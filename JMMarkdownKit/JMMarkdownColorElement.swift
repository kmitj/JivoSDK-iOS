//
// Created by Stan Potemkin on 2019-01-28.
// Copyright (c) 2019 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit
import UIKit

public final class JMMarkdownColorElement: CDMarkdownElement, CDMarkdownStyle {
    fileprivate static let regex = "\\[color=(\\w+)\\](.+?)\\[/color\\]"

    public var backgroundColor: UIColor?
    public var font: UIFont?
    public var color: UIColor?
    public var colorMap: [String: UIColor]?
    public var paragraphStyle: NSParagraphStyle?

    public func regularExpression() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
    }

    public var regex: String {
        return JMMarkdownColorElement.regex
    }

    public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        let colorCodeRange = match.range(at: 1)
        let colorCode = attributedString.attributedSubstring(from: colorCodeRange).string

        let textRange = match.range(at: 2)
        let text = attributedString.attributedSubstring(from: textRange)

        var attributes = generateAttributes()
        attributes[.foregroundColor] = colorMap?[colorCode] ?? color

        attributedString.replaceCharacters(in: match.range, with: text)
        attributedString.addAttributes(generateAttributes(), range: NSRange(location: 0, length: textRange.length))
    }
}
