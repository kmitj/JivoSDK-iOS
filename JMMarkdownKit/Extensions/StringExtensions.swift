//
//  StringExtensions.swift
//  JMMarkdown
//
//  Created by Stan Potemkin on 29/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

extension String {
    func substringTo(index: Int) -> String {
        if count <= index {
            return self
        }
        else {
            let pointer = self.index(startIndex, offsetBy: index)
            return String(self[...pointer])
        }
    }
    
    func clipBy(_ limit: Int?) -> String {
        guard let limit = limit else { return self }
        guard count >= limit else { return self }
        return substringTo(index: limit) + "…"
    }
}
