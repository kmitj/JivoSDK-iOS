//
// Created by Stan Potemkin on 27/11/2018.
// Copyright (c) 2018 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit
import UIKit

public final class JMMarkdownHrefElement: JMMarkdownClickableElement {
    fileprivate static let regex = "<a href=\"([^\"]+?)\">([^<]+?)</a>"

    public override var regex: String {
        return JMMarkdownHrefElement.regex
    }

    public override func regularExpression() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
    }

    init(font: UIFont? = nil, color: UIColor? = UIColor.blue, backgroundColor: UIColor? = nil) {
        super.init()
        
        self.font = font
        self.color = color
        self.backgroundColor = backgroundColor
    }

    public override func formatText(_ attributedString: NSMutableAttributedString, range: NSRange,
                           link: String) {
        guard linksEnabled else { return }
        guard let encodedLink = link.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let url = URL(string: link) ?? URL(string: encodedLink) else { return }
        attributedString.addAttribute(.link, value: url, range: range)
    }

    public override func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        let linkRange = match.range(at: 1)
        let link = (attributedString.string as NSString).substring(with: linkRange)

        let titleRange = match.range(at: 2)
        let title = (attributedString.string as NSString).substring(with: titleRange).clipBy(maxLength)

        let activeAttributes = attributedString.attributes(at: match.range.location, effectiveRange: nil)
        let replaceWithString = NSAttributedString(string: title, attributes: activeAttributes)
        attributedString.replaceCharacters(in: match.range, with: replaceWithString)

        let formatRange = NSRange(location: match.range.location, length: titleRange.length)
        formatText(attributedString, range: formatRange, link: link)
        addAttributes(attributedString, range: formatRange, link: link)
    }

    public override func addAttributes(_ attributedString: NSMutableAttributedString, range: NSRange, link: String) {
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
