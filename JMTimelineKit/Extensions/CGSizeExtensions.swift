//
//  CGSizeExtensions.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

extension CGSize: Comparable {
    func extendedBy(insets: UIEdgeInsets) -> CGSize {
        return CGSize(
            width: insets.left + width + insets.right,
            height: insets.top + height + insets.bottom
        )
    }
    
    public static func <(lhs: CGSize, rhs: CGSize) -> Bool {
        guard lhs.width < rhs.width else { return false }
        guard lhs.height < rhs.height else { return false }
        return true
    }
}
