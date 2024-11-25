//
//  LocaleExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 21/06/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation

extension Locale {
    var jv_langId: String {
        let parts = identifier.components(separatedBy: .punctuationCharacters)
        return parts.first ?? identifier
    }
    
    var jv_countryID: String? {
        let parts = identifier.components(separatedBy: .punctuationCharacters)
        if parts.count > 1 {
            return parts.last
        }
        else {
            return nil
        }
    }
    
    var jv_nativeTitle: String {
        if let name = (self as NSLocale).displayName(forKey: .languageCode, value: identifier) {
            return name.capitalized
        }
        else {
            return identifier
        }
    }
}
