//
//  UIEdgeInsetsExtensions.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    func reduceBy(insets: UIEdgeInsets) -> CGRect {
        return CGRect(
            x: origin.x + insets.left,
            y: origin.y + insets.top,
            width: width - insets.left - insets.right,
            height: height - insets.top - insets.bottom
        )
    }
    
    func divide(by axis: NSLayoutConstraint.Axis, number: Int) -> [CGRect] {
        switch axis {
        case .horizontal:
            let base = divided(atDistance: height / CGFloat(number), from: .minYEdge).slice
            return (0 ..< number).map { index in
                return base.offsetBy(dx: 0, dy: base.height * CGFloat(index))
            }
            
        case .vertical:
            let base = divided(atDistance: width / CGFloat(number), from: .minXEdge).slice
            return (0 ..< number).map { index in
                return base.offsetBy(dx: base.width * CGFloat(index), dy: 0)
            }
            
        @unknown default:
            let base = divided(atDistance: height / CGFloat(number), from: .minYEdge).slice
            return (0 ..< number).map { index in
                return base.offsetBy(dx: 0, dy: base.height * CGFloat(index))
            }
        }
    }
}
