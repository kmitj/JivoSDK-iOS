//
//  JMLazyEvaluator.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19/08/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

public final class JMLazyEvaluator<S, T> {
    private let evaluateBlock: (S) -> T
    private var internalValue: T?
    
    public init(block: @escaping (S) -> T) {
        evaluateBlock = block
    }
    
    public func value(input: S) -> T {
        if let v = internalValue {
            return v
        }
        else {
            let v = evaluateBlock(input)
            internalValue = v
            return v
        }
    }
}
