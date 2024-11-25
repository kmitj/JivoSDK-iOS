//
//  JMMarkdownOverpaintElement.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 27/06/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import JFMarkdownKit

public final class JMMarkdownOverpaintElement: CDMarkdownBold {
    fileprivate static let regex = "(^|\\s*)(<mask>)(.*?)(</mask>)"
    
    public init() {
        super.init(font: nil, customBoldFont: nil, color: nil, backgroundColor: nil)
    }
    
    override public var regex: String {
        return JMMarkdownOverpaintElement.regex
    }
}
