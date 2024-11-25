//
//  StringExtensions.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

extension String {
    func escape() -> String? {
        return addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }
    
    func unescape() -> String? {
        return removingPercentEncoding
    }
}
