//
//  JMInternalImageView.swift
//  JMRepicView
//
//  Created by Stan Potemkin on 23/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

final class JMInternalImageView: UIImageView {
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            guard newValue != UIColor.clear else { return }
            super.backgroundColor = newValue
        }
    }
}
