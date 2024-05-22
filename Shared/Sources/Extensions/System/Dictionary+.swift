//
//  DictionaryExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 05/07/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

extension Dictionary {
    static var jv_empty: Self {
        return .init()
    }
}

func +<K, V>(first: Dictionary<K, V>, second: Dictionary<K, V>) -> Dictionary<K, V> {
    var result = first
    for (k, v) in second { result[k] = v }
    return result
}
