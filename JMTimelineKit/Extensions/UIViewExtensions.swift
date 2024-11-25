//
//  UIViewExtensions.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func size(for width: CGFloat) -> CGSize {
        let containerSize = CGSize(width: width, height: .infinity)
        return sizeThatFits(containerSize)
    }
}
