//
//  URLExtensions.swift
//  JMMarkdown
//
//  Created by Stan Potemkin on 29/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

extension URL {
    static func mailto(mail: String) -> URL? {
        return URL(string: "mailto:\(mail)")
    }
    
    static func call(phone: String) -> URL? {
        let badSymbols = NSCharacterSet(charactersIn: "+0123456789").inverted
        let goodPhone = phone.components(separatedBy: badSymbols).joined()
        return URL(string: "tel:\(goodPhone)")
    }
}
