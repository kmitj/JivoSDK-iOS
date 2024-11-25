//
//  JMMarkdownMentionElement.swift
//  JMMarkdown
//
//  Created by Stan Potemkin on 27.01.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit

public enum JMMarkdownMentionOrigin {
    case person(String)
    case group(String)
}

public struct JMMarkdownMentionMeta {
    let caption: String
    let type: String
    let identifier: String?
    
    public init(caption: String, type: String, identifier: String?) {
        self.caption = caption
        self.type = type
        self.identifier = identifier
    }
}

public typealias JMMarkdownMentionProvider = (JMMarkdownMentionOrigin) -> JMMarkdownMentionMeta?

fileprivate let personPrefix = "@"
fileprivate let groupPrefix = "!"
fileprivate let summaryPrefix = [personPrefix, groupPrefix].joined()

final public class JMMarkdownMentionElement: JMMarkdownClickableElement {
    fileprivate static let regex = "(?:^|\\s+|\\B)((<)([\(summaryPrefix)]\\w+)(>))"
    
    public var mentionProvider: JMMarkdownMentionProvider?

    final override public var regex: String {
        return JMMarkdownMentionElement.regex
    }
    
    override public func regularExpression() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
    }
    
    override public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        let mentionRange = match.range(at: 3)
        let mention = (attributedString.string as NSString).substring(with: mentionRange)
        
        guard attributedString.attribute(.link, at: mentionRange.lowerBound, effectiveRange: nil) == nil else {
            return
        }
        
        let specialCharacters = CharacterSet(charactersIn: summaryPrefix)
        let commonID = mention.trimmingCharacters(in: specialCharacters)
        
        let replacementMeta: JMMarkdownMentionMeta
        if mention.hasPrefix(personPrefix) {
            guard let meta = mentionProvider?(.person(commonID)) else { return }
            replacementMeta = meta
        }
        else if mention.hasPrefix(groupPrefix) {
            guard let meta = mentionProvider?(.group(commonID)) else { return }
            replacementMeta = meta
        }
        else {
            return
        }

        let entireRange = match.range(at: 1)
        
        let activeAttributes = attributedString.attributes(at: match.range.location, effectiveRange: nil)
        let replaceWithString = NSAttributedString(string: replacementMeta.caption, attributes: activeAttributes)
        attributedString.replaceCharacters(in: entireRange, with: replaceWithString)
        
        let formatRange = NSRange(location: entireRange.location, length: replacementMeta.caption.count)
        addAttributes(attributedString, range: formatRange, meta: replacementMeta)
    }
    
    private func addAttributes(_ attributedString: NSMutableAttributedString, range: NSRange, meta: JMMarkdownMentionMeta) {
        if let color = color {
            attributedString.addAttributes([.foregroundColor: color], range: range)
        }
        
        if linksEnabled, let identifier = meta.identifier, let url = URL(string: "//mention?\(meta.type)#\(identifier)") {
            addURL(attributedString, range: range, url: url)
        }
    }
}
