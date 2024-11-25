//
//  JMMarkdownPhoneElement.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 26/06/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit

public final class JMMarkdownPhoneElement: JMMarkdownClickableElement {
    override public var regex: String {
        if let result = try? regularExpression().pattern {
            return result
        }
        else {
            abort()
        }
    }
    
    override public func regularExpression() throws -> NSRegularExpression {
        return try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
    }

    override public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        let linkRange = match.range
        let link = (attributedString.string as NSString).substring(with: linkRange)
        
        let titleRange = match.range
        let title = (attributedString.string as NSString).substring(with: titleRange)
        
        let activeAttributes = attributedString.attributes(at: match.range.location, effectiveRange: nil)
        let replaceWithString = NSAttributedString(string: title, attributes: activeAttributes)
        attributedString.replaceCharacters(in: match.range, with: replaceWithString)
        
        let formatRange = NSRange(location: match.range.location, length: titleRange.length)
        addAttributes(attributedString, range: formatRange, link: link)
    }
    
    override public func addAttributes(_ attributedString: NSMutableAttributedString, range: NSRange, link: String) {
        super.addAttributes(attributedString, range: range, link: link)
        
        guard let encodedLink = link.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let url = URL.call(phone: link) ?? URL.call(phone: encodedLink) else { return }
        addURL(attributedString, range: range, url: url)
    }
}
