//
//  UILabelExtensions.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 29/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    var hasText: Bool {
        if let text = text {
            return !text.isEmpty
        }
        else {
            return false
        }
    }
    
    func calculateHeight(for width: CGFloat) -> CGFloat {
        if hasText {
            let bounds = CGRect(x: 0, y: 0, width: width, height: .infinity)
            return textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).height
        }
        else {
            return font.lineHeight
        }
    }
}
