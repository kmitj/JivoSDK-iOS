//
//  CGAffineTransformExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 18/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit

extension CGAffineTransform {
    static var invertedVertically: CGAffineTransform {
        return .init(scaleX: 1, y: -1)
    }
}
