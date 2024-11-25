//
//  JMTimelineCanvas.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

@objc public enum JMTimelineContentInteractionResult: Int {
    case incorrect
    case handled
    case unhandled
}

open class JMTimelineCanvas: UIView, JMTimelineStylable {
    public private(set) var item: JMTimelineItem?
    
    public init() {
        super.init(frame: .zero)
        updateDesign()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configure(item: JMTimelineItem) {
        self.item = item
        setNeedsLayout()
    }
    
    open func updateDesign() {
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateDesign()
    }
    
    open func handleLongPressInteraction(gesture: UILongPressGestureRecognizer) -> JMTimelineContentInteractionResult {
        return .unhandled
    }
}
