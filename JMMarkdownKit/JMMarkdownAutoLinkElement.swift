//
//  JMMarkdownAutoLinkElement.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 27/06/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

public final class JMMarkdownAutoLinkElement: JMMarkdownClickableElement {
    override public var regex: String {
        if let result = try? regularExpression().pattern {
            return result
        }
        else {
            abort()
        }
    }
    
    override public func regularExpression() throws -> NSRegularExpression {
        return try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    }
    
    override public func match(_ match: NSTextCheckingResult,
                             attributedString: NSMutableAttributedString) {
        let linkURLString = attributedString.attributedSubstring(from: match.range).string
        addAttributes(attributedString, range: match.range, link: linkURLString)
        formatText(attributedString, range: match.range, link: linkURLString)
    }

    override public func addAttributes(_ attributedString: NSMutableAttributedString, range: NSRange, link: String) {
        super.addAttributes(attributedString, range: range, link: link)
        
        let normalLink = normalizedLink(link)
        let normalURL = NSURL(string: normalLink)
        
        let encodedLink = link.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let encodedURL = NSURL(string: encodedLink ?? link)
        
        if let url = normalURL ?? encodedURL {
            addURL(attributedString, range: range, url: url as URL)
        }
    }
    
    override public func formatText(_ attributedString: NSMutableAttributedString, range: NSRange, link: String) {
        guard let maxLength = maxLength, range.length > maxLength else { return }
        
        let shortRange = NSMakeRange(range.location, maxLength)
        let shortLink = attributedString.attributedSubstring(from: shortRange)
        attributedString.replaceCharacters(in: range, with: shortLink)
    }
    
    private func normalizedLink(_ link: String) -> String {
        guard URLComponents(string: link)?.scheme == nil else { return link }
        guard !link.contains("@") else { return link }
        return "http://" + link
    }
}
