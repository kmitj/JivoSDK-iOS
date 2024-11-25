//
//  JMMarkdownClickableElement.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 28/06/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit
import UIKit

public class JMMarkdownClickableElement: CDMarkdownLinkElement {
    public var font: UIFont?
    public var color: UIColor?
    public var backgroundColor: UIColor?
    public var maxLength: Int?
    public var paragraphStyle: NSParagraphStyle?
    public var underlineStyle: NSUnderlineStyle?
    public var linksEnabled: Bool = true
    
    public var regex: String {
        abort()
    }
    
    public func regularExpression() throws -> NSRegularExpression {
        abort()
    }
    
    public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
    }
    
    public func formatText(_ attributedString: NSMutableAttributedString, range: NSRange, link: String) {
    }
    
    public func addAttributes(_ attributedString: NSMutableAttributedString, range: NSRange, link: String) {
        var extendedAttributes = generateAttributes()
        extendedAttributes[.underlineStyle] = underlineStyle.flatMap { NSNumber(value: $0.rawValue) }
        attributedString.addAttributes(extendedAttributes, range: range)
    }
    
    func addURL(_ attributedString: NSMutableAttributedString, range: NSRange, url: URL) {
        guard linksEnabled else { return }
        attributedString.addAttribute(.link, value: url, range: range)
    }
}
