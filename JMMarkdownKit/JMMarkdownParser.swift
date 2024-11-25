//
//  JMMarkdownParser.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 15/12/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JFMarkdownKit
import TypedTextAttributes

public enum JMMarkdownParserType {
    case header
    case bold
    case color
    case autoLink
    case link
    case href
    case image
    case list
    case center
    case email
    case phone
    case overpaint
    case mention
    case mdItalics
    case mdBold
    case mdStrike
    case mdLink
}

struct JMMarkdownParsedValue {
    let type: JMMarkdownParserType
    let range: NSRange
    let string: String
}

public final class JMMarkdownParser: CDMarkdownParser {
    public lazy var headerElement = JMMarkdownHeaderElement()
    public lazy var mdItalicsElement = JMMarkdownMdItalicsElement()
    public lazy var boldElement = JMMarkdownBoldElement()
    public lazy var mdBoldElement = JMMarkdownMdBoldElement()
    public lazy var mdStrikeElement = JMMarkdownMdStrikeElement()
    public lazy var mdLinkElement = JMMarkdownMdLinkElement()
    public lazy var colorElement = JMMarkdownColorElement()
    public lazy var autoLinkElement = JMMarkdownAutoLinkElement()
    public lazy var linkElement = JMMarkdownLinkElement()
    public lazy var hrefElement = JMMarkdownHrefElement()
    public lazy var imageElement = JMMarkdownImageElement()
    public lazy var centerElement = JMMarkdownCenterElement()
    public lazy var listElement = JMMarkdownListElement()
    public lazy var emailElement = JMMarkdownEmailElement()
    public lazy var phoneElement = JMMarkdownPhoneElement()
    public lazy var overpaintElement = JMMarkdownOverpaintElement()
    public lazy var mentionElement = JMMarkdownMentionElement()

    private var additionalAttributes = TextAttributes()
    private(set) public var types = [JMMarkdownParserType]()
    private var cachingLimit: Int?
    private var parsingMap = [(JMMarkdownParserType, () -> CDMarkdownElement)]()
    private var parsingCache = NSCache<NSAttributedString, NSAttributedString>()
    
    public convenience init(font: UIFont, color: UIColor, additionalAttributes: TextAttributes, types: [JMMarkdownParserType], cachingLimit: Int? = nil) {
        self.init(font: font, fontColor: color)
        
        self.additionalAttributes = additionalAttributes
        self.types = types
        self.cachingLimit = cachingLimit
        
        parsingMap = [
            (.header, {[unowned self] in self.headerElement}),
            (.bold, {[unowned self] in self.boldElement}),
            (.mdBold, {[unowned self] in self.mdBoldElement}),
            (.mdItalics, {[unowned self] in self.mdItalicsElement}),
            (.mdStrike, {[unowned self] in self.mdStrikeElement}),
            (.mdLink, {[unowned self] in self.mdLinkElement}),
            (.color, {[unowned self] in self.colorElement}),
            (.autoLink, {[unowned self] in self.autoLinkElement}),
            (.link, {[unowned self] in self.linkElement}),
            (.href, {[unowned self] in self.hrefElement}),
            (.email, {[unowned self] in self.emailElement}),
            (.image, {[unowned self] in self.imageElement}),
            (.list, {[unowned self] in self.listElement}),
            (.center, {[unowned self] in self.centerElement}),
            (.phone, {[unowned self] in self.phoneElement}),
            (.overpaint, {[unowned self] in self.overpaintElement}),
            (.mention, {[unowned self] in self.mentionElement})
        ]
        
        elementsForTypes(types).forEach(addCustomElement)
    }
    
    public func parse(_ markdown: String, attributes: TextAttributes) -> NSAttributedString {
        return parse(NSAttributedString(string: markdown), attributes: attributes)
    }
    
    public func parse(_ markdown: NSAttributedString, attributes: TextAttributes) -> NSAttributedString {
        if let cachedResult = parsingCache.object(forKey: markdown) {
            return cachedResult
        }
        else {
            let attributedString = NSMutableAttributedString(attributedString: markdown)
            
            attributedString.addAttributes(
                attributes
                    .font(font)
                    .foregroundColor(fontColor)
                    .backgroundColor(backgroundColor),
                range: NSRange(
                    location: 0,
                    length: attributedString.length
                )
            )
            
            customElements.forEach { element in
                element.parse(attributedString)
            }

            if let limit = cachingLimit, attributedString.string.count > limit {
                parsingCache.setObject(attributedString, forKey: markdown, cost: attributedString.string.count)
            }
            
            return attributedString
        }
    }
    
    override public func parse(_ markdown: NSAttributedString) -> NSAttributedString {
        return parse(markdown, attributes: additionalAttributes)
    }
    
    func scan(_ string: String) -> [JMMarkdownParsedValue] {
        var values = [JMMarkdownParsedValue]()
        
        let elements = elementsForTypes(types)
        zip(types, elements).forEach { type,  element in
            guard let expression = try? element.regularExpression() else { return }
            
            let range = NSMakeRange(0, string.count)
            let matches = expression.matches(in: string, options: [], range: range)
            
            for match in matches {
                values.append(
                    JMMarkdownParsedValue(
                        type: type,
                        range: match.range,
                        string: (string as NSString).substring(with: match.range)
                    )
                )
            }
        }
        
        return values
    }
    
    private func elementsForTypes(_ types: [JMMarkdownParserType]) -> [CDMarkdownElement] {
        return parsingMap.compactMap { (type, elementProvider) in
            guard types.contains(type) else { return nil }
            return elementProvider()
        }
    }
}

extension CDMarkdownStyle {
    func generateAttributes() -> [NSAttributedString.Key: AnyObject] {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.font] = font
        attributes[.foregroundColor] = color
        attributes[.backgroundColor] = backgroundColor
        return attributes
    }
}
