//
//  JMMarkdownMdBoldElement.swift
//  JMMarkdown
//
//  Created by Stan Potemkin on 07.08.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit

public final class JMMarkdownMdBoldElement: CDMarkdownBold {
    fileprivate static let regex = "()(\\*\\*|__)(.+?)(\\2)"
    
    public init() {
        super.init(font: nil, customBoldFont: nil, color: nil, backgroundColor: nil)
    }
    
    override public var regex: String {
        return JMMarkdownMdBoldElement.regex
    }
}
