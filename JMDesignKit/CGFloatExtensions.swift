//
//  CGFloatExtensions.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 29/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    public func scaled(category: UIFont.TextStyle, multiplier: CGFloat = 1.0, maximum: CGFloat? = nil) -> CGFloat {
        let result: CGFloat
        if #available(iOS 11.0, *) {
            result = UIFontMetrics(forTextStyle: category).scaledValue(for: self)
        }
        else {
            result = self
        }
        
        if let maximum = maximum, let minimum = [maximum, result].min() {
            return minimum * multiplier
        }
        else {
            return result * multiplier
        }
    }
}
