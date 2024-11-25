//
//  JMTimelineCompositeSenderLabel.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 05.08.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public final class JMTimelineCompositeSenderLabel: UILabel {
    public var padding = UIEdgeInsets.zero
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let original = super.sizeThatFits(size)
        return original.extendedBy(insets: padding)
    }
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.reduceBy(insets: padding))
    }
}
