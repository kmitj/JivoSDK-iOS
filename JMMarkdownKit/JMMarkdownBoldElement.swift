//
//  JMMarkdownBoldElement.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 22/12/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit

public final class JMMarkdownBoldElement: CDMarkdownBold {
    fileprivate static let regex = "(\\s+|^)(\\[b\\])(.+?)(\\[/b\\])"
    
    public init() {
        super.init(font: nil, customBoldFont: nil, color: nil, backgroundColor: nil)
    }
    
    override public var regex: String {
        return JMMarkdownBoldElement.regex
    }
}
