//
//  JMMarkdownListElement.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 12/01/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit

public final class JMMarkdownListElement: CDMarkdownList {
    public var additionalAttributes = [NSAttributedString.Key: AnyObject]()
    
    override public func formatText(_ attributedString: NSMutableAttributedString, range: NSRange, level: Int) {
        super.formatText(attributedString, range: range, level: level)
        attributedString.addAttributes(additionalAttributes, range: range)
    }
}
