//
//  CGSizeExtensions.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 29/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

extension CGSize {
    public func scaled(category: UIFont.TextStyle, multiplier: CGFloat = 1.0) -> CGSize {
        return CGSize(
            width: width.scaled(category: category, multiplier: multiplier),
            height: height.scaled(category: category, multiplier: multiplier)
        )
    }
}
